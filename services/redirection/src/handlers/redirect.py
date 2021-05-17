import os
import json
import logging
import datetime as dt

from pynamodb.exceptions import DoesNotExist
import boto3

from src.models import ShortenedLink
from src.exceptions import ExternalError, InternalError


client = boto3.client('events')

logger = logging.getLogger(__name__)
if os.environ['STAGE'] == 'dev':
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)


def handler(event, context):
    logger.debug(f'Processing event: {event}')
    try:
        link_id = event['pathParameters']['linkId']
        if not link_id:
            return {
                'statusCode': 302,
                'headers': {
                    'Location': 'https://shortrlink.com/'
                }
            }
        link = ShortenedLink.get(link_id, 'LINK')

        # Make known that someone actually used the service
        res = client.put_events(
            Entries=[
                {
                    'Time': dt.datetime.now(),
                    'Source': 'aws.lambda',
                    'Resources': [
                        context.invoked_function_arn
                    ],
                    'DetailType': 'shortrLink user redirect',
                    'Detail': json.dumps({
                        'link_id': link_id,
                        'ip': event['requestContext']['sourceIp'],
                        'user_agent': event['requestContext']['userAgent'],
                        'origin': event['headers'].get('Origin', ''),
                        'headers': event['headers']
                    }),
                    'EventBusName': os.environ['EVENT_BUS_NAME'],
                    'TraceHeader': event['headers']['x-amzn-trace-id']
                },
            ]
        )
        if res['FailedEntryCount']:
            logger.exception(f'Failed publishing click/redirect event.')

        return {
            'statusCode': 302,
            'headers': {
                'Location': link.url
            }
        }
    except DoesNotExist:
        return {
            'statusCode': 404,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            },
            'body': json.dumps({
                'message': f'Provided redirection id {link_id} could not be found'
            })
        }
    except KeyError as e:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            },
            'body': json.dumps({
                'message': 'No redirection parameter supplied.'
            })
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            },
            'body': json.dumps({
                'message': str(e)
            })
        }



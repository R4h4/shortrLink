import os
import json
import logging
import datetime as dt

from shortid import ShortId
import boto3
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

from src.models import ShortenedLink
from src.exceptions import ExternalError, InternalError

client = boto3.client('events')

# apply the XRay handler to all clients.
patch_all()

shortid = ShortId()
logger = logging.getLogger(__name__)
if os.environ['STAGE'] == 'dev':
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)


def handler(event, context):
    """
    Creates a shortened link for a given URL and returns said URL
    :param event:
    :param context:
    :return:
    """
    logger.debug(f'Received event: {event}')
    try:
        try:
            body = json.loads(event['body'])
        except json.JSONDecodeError:
            raise ExternalError('Body is not a valid JSON string')
        try:
            username = event['requestContext']['authorizer']['jwt']['claims']['username']
            logger.debug(f'Request from user: {username}')
        except KeyError:
            username = None
            logger.debug('Creating anonymous link')

        if not body['url'].startswith('http'):
            body['url'] = 'https://' + body['url']

        try:
            link = ShortenedLink(
                id=shortid.generate(),
                url=body['url'],
                user=username
            )
            link.save()
        except KeyError as e:
            raise ExternalError(f'Invalid input body/missing fields: {e}')

        # Let known that we created a link. Using event publishing instead of DynamodDb stream to avoid unecessary
        # Lambda invocations on updates
        try:
            res = client.put_events(
                Entries=[
                    {
                        'Time': dt.datetime.now(),
                        'Source': 'shortrLinks.lambda',
                        'Resources': [
                            context.invoked_function_arn
                        ],
                        'DetailType': 'shortrLink link created',
                        'Detail': json.dumps({
                            'link_id': link.id
                        }),
                        'EventBusName': os.environ['EVENT_BUS_NAME']
                    },
                ]
            )
            if res.get('FailedEntryCount'):
                logger.exception(f'Failed publishing click/redirect event. result: {res}')
        except Exception as e:
            logger.exception(f'Error putting event: {str(e)}')

        return {
            'statusCode': 201,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            },
            'body': json.dumps({
                'id': link.id,
                'shortUrl': 'https://' + os.environ['BASE_DOMAIN'] + f'/{link.id}',
                'url': link.url
            })
        }
    except InternalError as e:
        logger.error(str(e))
        return {
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            },
            'statusCode': 500,
            'body': json.dumps({
                'message': str(e)
            })
        }
    except ExternalError as e:
        logger.error(str(e))
        return {
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            },
            'statusCode': 400,
            'body': json.dumps({
                'message': str(e)
            })
        }
    except Exception as e:
        logger.error(str(e))
        return {
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            },
            'statusCode': 500,
            'body': json.dumps({
                'message': f"An undefined error happened: {str(e)}"
            })
        }
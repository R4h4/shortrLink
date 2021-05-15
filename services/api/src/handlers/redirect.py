import os
import json

from pynamodb.exceptions import DoesNotExist

from src.models import ShortenedLink
from src.exceptions import ExternalError, InternalError


def handler(event, context):
    try:
        link_id = event['pathParameters']['linkId']
        link = ShortenedLink.get(link_id, 'LINK')

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



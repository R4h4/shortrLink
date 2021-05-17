import os
import json
import logging

from shortid import ShortId

from src.models import ShortenedLink
from src.exceptions import ExternalError, InternalError


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
            link = ShortenedLink(
                id=shortid.generate(),
                url=body['url']
            )
            link.save()
        except KeyError as e:
            raise ExternalError(f'Invalid input body/missing fields: {e}')

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
import json
import os
import logging

from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

from src.models import ShortenedLink

patch_all()
logger = logging.getLogger(__name__)
if os.environ['STAGE'] == 'dev':
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)


def handler(event, context):
    logger.debug(event)
    username = event['requestContext']['authorizer']['jwt']['claims']['username']
    logger.debug(f'Request from user: {username}')

    links = ShortenedLink.user_created_index.query(hash_key=username)
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Credentials': True,
        },
        'body': json.dumps({
            'links': [
                {
                    'id': link.id,
                    'clicks': link.clicks,
                    'title': link.title,
                    'createdAt': str(link.createdAt),
                    'url': link.url,
                    'short_link': link.short_link
                } for link in links
            ],
            'lastToken': links.last_evaluated_key,
            'count': links.total_count
        })
    }

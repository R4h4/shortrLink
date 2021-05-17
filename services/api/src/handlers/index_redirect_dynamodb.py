import os
import json
import logging
import datetime as dt
from src.models import ShortenedLink


logger = logging.getLogger(__name__)
if os.environ['STAGE'] == 'dev':
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)


def handler(event, context):
    """Increment the click count on the DynamoDb item for the Link by 1"""
    logger.debug(f'Processing event: {event}')

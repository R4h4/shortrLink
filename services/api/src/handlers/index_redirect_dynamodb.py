import os
import logging

from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

from src.models import ShortenedLink

# apply the XRay handler to all clients.
patch_all()


logger = logging.getLogger(__name__)
if os.environ['STAGE'] == 'dev':
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)


def handler(event, context):
    """
    Increment the click count on the DynamoDb item for the Link by 1
    In theory, we could run into race conditions, but at a point where multiple clicks within ~10ms occur,
    approximations should be fine
    """
    logger.debug(f'Processing event: {event}')
    link = ShortenedLink.get(event['detail']['link_id'], 'LINK')
    link.update(actions=[ShortenedLink.clicks.set(ShortenedLink.clicks + 1)])

import os
import json
import logging
import datetime as dt

from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all
import requests
from requests.exceptions import MissingSchema, InvalidSchema, ConnectionError, Timeout
from lxml.html import fromstring

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
    Add information about the URL that we shorten to the ShortLink object (At the moment only the title)
    """
    logger.debug(f'Processing event: {event}')
    link = ShortenedLink.get(event['detail']['link_id'], 'LINK')

    try:
        res = requests.get(link.url)
    except (MissingSchema, InvalidSchema):
        link.update(actions=[
            ShortenedLink.is_valid.set(False),
            ShortenedLink.invalid_message.set("Missing/Invalid Schema in link. Try adding 'https://'")
        ])
    except (ConnectionError, Timeout):
        link.update(actions=[
            ShortenedLink.is_valid.set(False),
            ShortenedLink.invalid_message.set("ConnectionError/URL could not be reached")
        ])

    tree = fromstring(res.content)
    link.update(actions=[ShortenedLink.title.set(tree.findtext('.//title'))])

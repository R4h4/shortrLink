import os
import json
import logging
import dateutil.parser

import boto3
from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all

from src.models import ShortenedLink


logger = logging.getLogger(__name__)
if os.environ['STAGE'] == 'dev':
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)


client = boto3.client('timestream-write')

# apply the XRay handler to all clients.
patch_all()


def handler(event, context):
    """
    Write the click event into a timestream table for further analysis
    """
    logger.debug(f'Processing event: {event}')
    response = client.write_records(
        DatabaseName=os.environ['TIMESTREAM_DB'],
        TableName=os.environ['TIMESTREAM_TABLE_NAME'],
        Records=[
            {
                'Dimensions': [
                    {
                        'Name': 'user',
                        'Value': event['detail'].get('user', 'anonymous'),
                        'DimensionValueType': 'VARCHAR'
                    },
                    {
                        'Name': 'link_id',
                        'Value': event['detail']['link_id'],
                        'DimensionValueType': 'VARCHAR'
                    },
                ],
                # 'MeasureName': 'string',
                # 'MeasureValue': 'string',
                # 'MeasureValueType': 'DOUBLE' | 'BIGINT' | 'VARCHAR' | 'BOOLEAN',
                'Time': str(int(dateutil.parser.parse(event['time']).timestamp())),
                'TimeUnit': 'SECONDS'
            },
        ]
    )
    logger.info(response)
import traceback
import os
import json
import base64
import logging
from datetime import datetime

logger = logging.getLogger(__name__)
if os.environ['STAGE'] == 'dev':
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)


def handler(event, context):
    """Takes the redirection event (EventBridge -> Firehose) and flattens it"""
    logger.debug(event)
    output = list()
    for record in event['records']:
        data = record['data']
        message: dict = json.loads(base64.b64decode(data))
        try:
            # Flatten the message
            detail = message.pop('detail')
            message = {**message, **detail}
            message['resources'] = message['resources'][0]
            message['host'] = message['headers']['host']
        except Exception as e:
            message['transform_error_message'] = str(e)
            message['transform_error_type'] = type(e).__name__
            message['transform_error_traceback'] = traceback.format_exc()
            logger.exception(f'Error flattening the dict: {e}')
        output.append({
            'recordId': record['recordId'],
            'result': 'Ok',
            'data': base64.b64encode(json.dumps(message).encode('utf-8'))
        })

    return {'records': output}

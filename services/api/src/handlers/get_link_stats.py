import json
import os
import logging
import datetime as dt

from aws_xray_sdk.core import xray_recorder
from aws_xray_sdk.core import patch_all
import boto3
from mypy_boto3_timestream_query import TimestreamQueryClient
from mypy_boto3_timestream_query.type_defs import QueryResponseTypeDef
from mypy_boto3_timestream_query.paginator import (
    QueryPaginator,
)
from pynamodb.exceptions import DoesNotExist

from src.models import ShortenedLink
from src.exceptions import ExternalError, InternalError


client: TimestreamQueryClient = boto3.client('timestream-query')
patch_all()


logger = logging.getLogger(__name__)
if os.environ['STAGE'] == 'dev':
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)


class UnauthorizedError(Exception):
    """To be raised when someone tries to get statistics on a link that does not belong to them"""


def create_time_series(recordset: QueryResponseTypeDef, days: int):
    """
    Created a list of integers for the x days we are looking at.
    Timestream only returns bin with data, so we have to pad it with 0s for all other days
    """
    if not recordset['Rows']:
        return [0 for _ in range(days)]
    end = dt.datetime.now() + dt.timedelta(days=1)
    start = (end - dt.timedelta(days=14))
    step = dt.timedelta(days=1)

    time_series = []
    i = 0  # Iterrator through the timestream record set (ordered by the bin)
    while start < end:
        if recordset['Rows'][i]['Data'][0]['ScalarValue'] == start.strftime('%Y-%m-%d 00:00:00.000000000'):
            time_series.append(int(recordset['Rows'][i]['Data'][1]['ScalarValue']))
            i += 1
        else:
            time_series.append(0)
        start += step
    return time_series


def handler(event, context):
    logger.debug(f'Received event: {event}')
    link_id = event['pathParameters']['link_id']
    try:
        link = ShortenedLink.get(link_id, 'LINK')
        username = event['requestContext']['authorizer']['jwt']['claims']['username']
        if link.user != username:
            logger.info(f'User {username} tried to access a link that belongs to {link.user}')
            raise UnauthorizedError
        # Later, this might be variable
        days = 14
        # Get the actual link statistics
        two_weeks_query = f"""
        SELECT 
            BIN(time, 1d) AS binned_timestamp, 
            count(measure_value::boolean) as clicks
        FROM {os.environ['TIMESTREAM_DB']}.redirects
        WHERE 
            link_id = '{link_id}'
            and time > ago({days}d)
        GROUP BY BIN(time, 1d)
        """
        res = client.query(QueryString=two_weeks_query)
        time_series = create_time_series(res, days=days)

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            },
            'body': json.dumps({
                'timeSeries': time_series,
                'days': days
            })
        }
    except DoesNotExist:
        return {
            'statusCode': 404,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            }
        }
    except UnauthorizedError:
        return {
            'statusCode': 401,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Credentials': True,
            }
        }
    except Exception as e:
        logger.exception(e)
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
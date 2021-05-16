class ExternalError(Exception):
    """An Error to be raised when something in the provided request is faulty (code 4xx)"""


class InternalError(Exception):
    """An Error to be raised on any form of internal issues (code 5xx)"""

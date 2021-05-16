import os
from datetime import datetime

from pynamodb.attributes import UnicodeAttribute, UTCDateTimeAttribute
from pynamodb.models import Model


class ShortenedLink(Model):
    class Meta:
        table_name = os.environ['DYNAMODB_TABLE']
        if 'ENV' in os.environ:
            host = 'http://localhost:8000'
        else:
            region = os.environ['REGION']
            host = f'https://dynamodb.{region}.amazonaws.com'
        # Arbitrary to avoid errors
        read_capacity_units = 1
        write_capacity_units = 1

    PK = UnicodeAttribute(hash_key=True)
    SK = UnicodeAttribute(range_key=True)
    _type = UnicodeAttribute(default='ShortenedLink')

    id = UnicodeAttribute(null=False)
    url = UnicodeAttribute(null=False)
    user = UnicodeAttribute(null=True)

    createdAt = UTCDateTimeAttribute(null=False, default=datetime.now())
    updatedAt = UTCDateTimeAttribute(null=False)

    def save(self, conditional_operator=None, **expected_values):
        self.updatedAt = datetime.now()
        self.PK = self.id
        self.SK = 'LINK'
        super(ShortenedLink, self).save()

    def __iter__(self):
        for name, attr in self.get_attributes().items():
            yield name, attr.serialize(getattr(self, name))

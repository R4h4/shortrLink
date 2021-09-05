resource "aws_glue_catalog_database" "data_lake_prepared" {
  name = lower("${var.app_name}_${var.stage}_datalake_prepared")
}

resource "aws_glue_catalog_table" "redirects" {
  database_name = aws_glue_catalog_database.data_lake_prepared.name
  name          = "redirects"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }

  partition_keys {
    name = "year"
    type = "string"
  }
  partition_keys {
    name = "month"
    type = "string"
  }
  partition_keys {
    name = "day"
    type = "string"
  }
  partition_keys {
    name = "hour"
    type = "string"
  }

  storage_descriptor {
    location = "s3://${element(split(":", aws_s3_bucket.prepared_events.arn), 5)}/redirects"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    ser_de_info {
      name                  = "my-stream"
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"

      parameters = {
        "serialization.compression" = "SNAPPY"
      }
    }

    columns {
      name = "version"
      type = "string"
    }
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "detail-type"
      type = "string"
    }
    columns {
      name = "source"
      type = "string"
    }
    columns {
      name = "account"
      type = "string"
    }
    columns {
      name = "time"
      type = "date"
    }
    columns {
      name = "region"
      type = "string"
    }
    columns {
      name = "resources"
      type = "string"
    }
    columns {
      name = "link_id"
      type = "string"
    }
    columns {
      name = "ip"
      type = "string"
    }
    columns {
      name = "user_agent"
      type = "string"
    }
    columns {
      name = "origin"
      type = "string"
    }
    columns {
      name = "headers"
      type = "string"
    }
    columns {
      name = "user"
      type = "string"
    }
    columns {
      name = "host"
      type = "string"
    }
  }
}
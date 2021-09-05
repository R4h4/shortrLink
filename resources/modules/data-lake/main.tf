data "aws_lambda_function" "raw_redirect_transform" {
  function_name = "data-lake-transform-${var.stage}-transformRedirectEvents"
}

resource "aws_kinesis_firehose_delivery_stream" "redirects" {
  destination = "extended_s3"
  name        = "${var.app_name}-raw-redirect-events-${var.stage}"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.prepared_events.arn
    prefix              = "redirects/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "error-redirects/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/!{firehose:random-string}/"
    s3_backup_mode      = "Enabled"
    buffer_size         = 64
    buffer_interval     = 300

    s3_backup_configuration {
      role_arn            = aws_iam_role.firehose_role.arn
      bucket_arn          = aws_s3_bucket.raw_events.arn
      # Deactivated until https://github.com/hashicorp/terraform-provider-aws/pull/13416 is merged (adds support of error_output_prefix)
//      prefix              = "redirects/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
      buffer_size         = 15
      buffer_interval     = 300
      compression_format  = "GZIP"
    }

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_errors.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_errors.name
    }
    processing_configuration {
      enabled = "true"

      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${data.aws_lambda_function.raw_redirect_transform.arn}:$LATEST"
        }
        parameters {
          parameter_name  = "NumberOfRetries"
          parameter_value = 0
        }
      }
    }
    data_format_conversion_configuration {
      input_format_configuration {
        deserializer {
          open_x_json_ser_de {}
        }
      }
      output_format_configuration {
        serializer {
          parquet_ser_de {
            compression = "SNAPPY"
//            writer_version = "V2"
          }
        }
      }
      schema_configuration {
        database_name = aws_glue_catalog_database.data_lake_prepared.name
        table_name = aws_glue_catalog_table.redirects.name
        role_arn = aws_iam_role.firehose_glue_conversion.arn
      }
    }
  }
  depends_on = [aws_iam_role_policy.access_glue_table_for_firehose]
}

resource "aws_kinesis_firehose_delivery_stream" "link_events" {
  destination = "extended_s3"
  name        = "${var.app_name}-raw-link-events-${var.stage}"

  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.raw_events.arn
    prefix              = "link-events/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "error-link-events/!{firehose:error-output-type}/!{timestamp:yyyy/MM/dd}/"
  }
}

resource "aws_cloudwatch_log_group" "firehose_errors" {
  name = "/aws/firehose/${var.app_name}-${var.stage}-error-logs"
}

resource "aws_cloudwatch_log_stream" "firehose_errors" {
  log_group_name  = aws_cloudwatch_log_group.firehose_errors.name
  name            = "${var.app_name}-error-log-stream-${var.stage}"
}

resource "aws_cloudwatch_event_rule" "user_links" {
  event_bus_name  = var.eventbus_name
  name            = "capture-user-link-events"
  description     = "Capture all CRUD link events by users"
  role_arn        = aws_iam_role.eventbridge.arn

  event_pattern = <<PATTERN
{
  "source": [
    "shortrLinks.lambda"
  ],
  "detail-type": [
    "shortrLink Create Successful",
    "shortrLink Deactivate Successful",
    "shortrLink Create Unsuccessful",
    "shortrLink Deactivate Unsuccessful"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "link_action" {
  event_bus_name  = var.eventbus_name
  arn             = aws_kinesis_firehose_delivery_stream.link_events.arn
  rule            = aws_cloudwatch_event_rule.user_links.name
  role_arn        = aws_iam_role.eventbridge.arn
}

resource "aws_cloudwatch_event_rule" "link_clicks" {
  event_bus_name  = var.eventbus_name
  name            = "capture-user-click-events"
  description     = "Capture all link click events"
  role_arn        = aws_iam_role.eventbridge.arn

  event_pattern = <<PATTERN
{
  "source": [
    "shortrLinks.lambda"
  ],
  "detail-type": [
    "shortrLink user redirect"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "link_click" {
  event_bus_name  = var.eventbus_name
  arn             = aws_kinesis_firehose_delivery_stream.redirects.arn
  rule            = aws_cloudwatch_event_rule.link_clicks.name
  role_arn        = aws_iam_role.eventbridge.arn
}
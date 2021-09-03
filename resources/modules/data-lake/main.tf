resource "aws_kinesis_firehose_delivery_stream" "first" {
  destination = "extended_s3"
  name        = "${var.app_name}-raw-events-${var.stage}"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.raw_events.arn


    cloudwatch_logging_options {
      enabled = true
      log_group_name = aws_cloudwatch_log_group.firehose_errors.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_errors.name
    }
  }
}

resource "aws_cloudwatch_log_group" "firehose_errors" {
  name = "/aws/firehose/${var.app_name}-${var.stage}-error-logs"
}

resource "aws_cloudwatch_log_stream" "firehose_errors" {
  log_group_name = aws_cloudwatch_log_group.firehose_errors.name
  name = "${var.app_name}-error-log-stream-${var.stage}"
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
  arn             = aws_kinesis_firehose_delivery_stream.first.arn
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
  arn             = aws_kinesis_firehose_delivery_stream.first.arn
  rule            = aws_cloudwatch_event_rule.link_clicks.name
  role_arn        = aws_iam_role.eventbridge.arn
}
resource "aws_s3_bucket" "raw_events" {
  bucket = "${var.app_name}-datalake-raw-${var.stage}"
  acl    = "private"
}

resource "aws_kinesis_firehose_delivery_stream" "first" {
  destination = "s3"
  name        = "${var.app_name}-raw-events-${var.stage}"

  s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.raw_events.arn
  }
}

resource "aws_iam_role" "firehose_role" {
  name = "${var.app_name}-firehose_role-${var.stage}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_rule" "user_links" {
  name        = "capture-user-link-events"
  description = "Capture all CRUD link events by users"

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
  arn             = aws_kinesis_firehose_delivery_stream.first
  rule            = aws_cloudwatch_event_rule.user_links.name
}

resource "aws_cloudwatch_event_rule" "link_clicks" {
  name        = "capture-user-click-events"
  description = "Capture all link click events"

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
  arn             = aws_kinesis_firehose_delivery_stream.first
  rule            = aws_cloudwatch_event_rule.link_clicks.name
}
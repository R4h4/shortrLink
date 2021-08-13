resource "aws_cloudwatch_event_bus" "main" {
  name = format("%s_%s_bus", local.app, local.stage)
}

data "aws_iam_policy_document" "aws_cloudwatch_event_bus_policy" {
  statement {
    effect  = "Allow"
    actions = ["events:PutEvents"]
    resources = [aws_cloudwatch_event_bus.main.arn]
  }
}

resource "aws_iam_role" "eventbridge_events" {
  name = "eventbridge_events_${local.stage}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "events.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "publish_events_to_eventbridge" {
  policy = data.aws_iam_policy_document.aws_cloudwatch_event_bus_policy.json
  role = aws_iam_role.eventbridge_events.id
}

resource "aws_cloudwatch_event_bus" "ap_southeast_1" {
  name = format("%s_%s_bus", local.app, local.stage)
  provider = aws.ap-southeast-1
}

resource "aws_cloudwatch_event_bus" "us_east_1" {
  name = format("%s_%s_bus", local.app, local.stage)
  provider = aws.us-east-1
}

resource "aws_cloudwatch_event_rule" "duplicate_events_us_east_1_rule" {
  name = "duplicate-events-for-cross-region"
  description = "Duplicates all events from us-east-1 into the primary region"
  event_bus_name = aws_cloudwatch_event_bus.us_east_1.name
  event_pattern = <<PATTERN
    {
      "source": [{"prefix": "" }]
    }
  PATTERN

  provider = aws.us-east-1
}

resource "aws_cloudwatch_event_target" "duplicate_events_us_east_1_target" {
  arn = aws_cloudwatch_event_bus.main.arn
  rule = aws_cloudwatch_event_rule.duplicate_events_us_east_1_rule.name
  event_bus_name = aws_cloudwatch_event_bus.us_east_1.name
  role_arn = aws_iam_role.eventbridge_events.arn

  provider = aws.us-east-1
}

resource "aws_cloudwatch_event_rule" "duplicate_events_ap_southeast_1_rule" {
  name = "duplicate-events-for-cross-region"
  description = "Duplicates all events FROM ap-southeast-1 into the primary region"
  event_bus_name = aws_cloudwatch_event_bus.ap_southeast_1.name
  event_pattern = <<PATTERN
    {
      "source": [{"prefix": "" }]
    }
  PATTERN

  provider = aws.ap-southeast-1
}

resource "aws_cloudwatch_event_target" "duplicate_events_ap_southeast_1_target" {
  arn = aws_cloudwatch_event_bus.main.arn
  rule = aws_cloudwatch_event_rule.duplicate_events_ap_southeast_1_rule.name
  event_bus_name = aws_cloudwatch_event_bus.ap_southeast_1.name
  role_arn = aws_iam_role.eventbridge_events.arn

  provider = aws.ap-southeast-1
}

resource "aws_ssm_parameter" "eventbus_name" {
  name = format("/%s/%s/eventbus_name", local.app,local.stage)
  type = "String"
  value = aws_cloudwatch_event_bus.main.name
}

resource "aws_ssm_parameter" "eventbus_name_us_east_1" {
  name = format("/%s/%s/eventbus_name", local.app,local.stage)
  type = "String"
  value = aws_cloudwatch_event_bus.main.name
  provider = aws.us-east-1
}

resource "aws_ssm_parameter" "eventbus_name_southeast_1" {
  name = format("/%s/%s/eventbus_name", local.app,local.stage)
  type = "String"
  value = aws_cloudwatch_event_bus.main.name
  provider = aws.ap-southeast-1
}
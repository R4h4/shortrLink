resource "aws_iam_role" "eventbridge" {
  name = "${var.app_name}_data-lake_eventbridge_role_${var.stage}"
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

data "aws_iam_policy_document" "put_firehose" {
  statement {
    sid       = "KinesisFirehoseAccess"
    effect    = "Allow"
    actions   = ["firehose:PutRecord", "firehose:PutRecordBatch"]
    resources = [
      aws_kinesis_firehose_delivery_stream.redirects.arn,
      aws_kinesis_firehose_delivery_stream.link_events.arn
    ]
  }
}

resource "aws_iam_policy" "firehose_policy" {
  policy = data.aws_iam_policy_document.put_firehose.json
  name   = "${var.app_name}-firehose-policy-${var.stage}"
}

resource "aws_iam_role_policy_attachment" "kinesis_firehose" {
  policy_arn = aws_iam_policy.firehose_policy.arn
  role       = aws_iam_role.eventbridge.name
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

data "aws_iam_policy_document" "put_s3_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.raw_events.arn, "${aws_s3_bucket.raw_events.arn}/*",
      aws_s3_bucket.prepared_events.arn, "${aws_s3_bucket.prepared_events.arn}/*"
    ]
  }
  statement {
    effect  = "Allow"
    actions = [
      "kinesis:DescribeStream",
      "kinesis:GetShardIterator",
      "kinesis:GetRecords",
      "kinesis:ListShards"
    ]
    resources = [
      aws_kinesis_firehose_delivery_stream.redirects.arn,
      aws_kinesis_firehose_delivery_stream.link_events.arn
    ]
  }
  statement {
    effect  = "Allow"
    actions = ["logs:PutLogEvents"]
    resources = [aws_cloudwatch_log_stream.firehose_errors.arn]
  }
  statement {
    effect  = "Allow"
    actions = ["lambda:InvokeFunction", "lambda:GetFunctionConfiguration"]
    resources = [
      "${data.aws_lambda_function.raw_redirect_transform.arn}:*",
      data.aws_lambda_function.raw_redirect_transform.arn
    ]
  }
}

resource "aws_iam_role_policy" "put_s3" {
  policy = data.aws_iam_policy_document.put_s3_policy.json
  role = aws_iam_role.firehose_role.id
}

resource "aws_iam_role" "firehose_glue_conversion" {
  name = "${var.app_name}-firehose_glue_conversion-${var.stage}"

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

data "aws_iam_policy_document" "data_lake_get_glue" {
  statement {
    effect  = "Allow"
    actions = [
      "glue:GetTable",
      "glue:GetTableVersion",
      "glue:GetTableVersions"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "access_glue_table_for_firehose" {
  policy = data.aws_iam_policy_document.data_lake_get_glue.json
  role = aws_iam_role.firehose_glue_conversion.id
}
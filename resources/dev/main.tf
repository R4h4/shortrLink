module "dynamodb_table" {
  source = "../modules/dynamodb"

  stream_enabled = true
  app_name       = local.app
  stage          = local.stage
}

resource "aws_ssm_parameter" "table_arn" {
  name  = format("/%s/%s/dynamodb_table_arn", local.app, local.stage)
  type  = "String"
  value = module.dynamodb_table.table_arn
}

resource "aws_ssm_parameter" "table_name" {
  name  = format("/%s/%s/dynamodb_table_name", local.app, local.stage)
  type  = "String"
  value = module.dynamodb_table.table_name
}

resource "aws_ssm_parameter" "table_name_us_east_1" {
  name     = format("/%s/%s/dynamodb_table_name", local.app, local.stage)
  type     = "String"
  value    = module.dynamodb_table.table_name
  provider = aws.us-east-1
}

resource "aws_ssm_parameter" "table_name_ap_southeast_1" {
  name     = format("/%s/%s/dynamodb_table_name", local.app, local.stage)
  type     = "String"
  value    = module.dynamodb_table.table_name
  provider = aws.ap-southeast-1
}

resource "aws_ssm_parameter" "dynamodb_stream_arn" {
  name  = format("/%s/%s/dynamodb_stream_arn", local.app, local.stage)
  type  = "String"
  value = module.dynamodb_table.stream_arn
}

module "timestreamdb" {
  source = "../modules/timestream"

  app_name = local.app
  stage    = local.stage
}

resource "aws_ssm_parameter" "timestream_db_name" {
  name  = format("/%s/%s/timestream_db_name", local.app, local.stage)
  type  = "String"
  value = module.timestreamdb.database_name
}

resource "aws_ssm_parameter" "timestream_redirectes_table_name" {
  name  = format("/%s/%s/timestream_redirects_table", local.app, local.stage)
  type  = "String"
  value = module.timestreamdb.redirects_table_name
}

module "data_lake" {
  source        = "../modules/data-lake"
  eventbus_name = aws_cloudwatch_event_bus.main.name
  app_name      = local.app
  stage         = local.stage
}
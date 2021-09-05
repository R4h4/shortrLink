terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "ke-terraform-backends"
    key = "state/startdust/sender_service.prod.tfstate"
    region = "eu-west-1"
    profile = "privateGmail"
  }
}


module "dynamodb_table" {
  source   = "../modules/dynamodb"

  stream_enabled = true
  app_name = local.app
  stage = local.stage
}

module "timestreamdb" {
  source = "../modules/timestream"

  app_name = local.app
  stage = local.stage
}

module "cloudfront_s3_website_with_domain" {
  source                 = "../modules/cloudfront-s3-website"
  hosted_zone            = "shortrlink.com"
  domain_name            = "shortrlink.com"
//  use_default_domain = true
  acm_certificate_domain = "*.shortrlink.com"
  website_domain_redirect = "www.shortrlink.com"
  app_name = local.app
  stage = local.stage
}

resource "aws_ssm_parameter" "website_bucket_name" {
  name = format("/%s/%s/app_bucket_name", local.app, local.stage)
  type = "String"
  value = module.cloudfront_s3_website_with_domain.s3_bucket_name
}

resource "aws_ssm_parameter" "timestream_db_name" {
  name = format("/%s/%s/timestream_db_name", local.app, local.stage)
  type = "String"
  value = module.timestreamdb.database_name
}

resource "aws_ssm_parameter" "timestream_redirectes_table_name" {
  name = format("/%s/%s/timestream_redirects_table", local.app, local.stage)
  type = "String"
  value = module.timestreamdb.redirects_table_name
}

resource "aws_ssm_parameter" "table_arn" {
  name = format("/%s/%s/dynamodb_table_arn", local.app, local.stage)
  type = "String"
  value = module.dynamodb_table.table_arn
}

resource "aws_ssm_parameter" "table_name" {
  name = format("/%s/%s/dynamodb_table_name", local.app,local.stage)
  type = "String"
  value = module.dynamodb_table.table_name
}

resource "aws_ssm_parameter" "table_name_us_east_1" {
  name = format("/%s/%s/dynamodb_table_name", local.app,local.stage)
  type = "String"
  value = module.dynamodb_table.table_name
  provider = aws.us-east-1
}

resource "aws_ssm_parameter" "table_name_ap_southeast_1" {
  name = format("/%s/%s/dynamodb_table_name", local.app,local.stage)
  type = "String"
  value = module.dynamodb_table.table_name
  provider = aws.ap-southeast-1
}

resource "aws_ssm_parameter" "dynamodb_stream_arn" {
  name = format("/%s/%s/dynamodb_stream_arn", local.app,local.stage)
  type = "String"
  value = module.dynamodb_table.stream_arn
}

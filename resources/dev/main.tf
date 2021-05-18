locals {
  stage = "dev"
  app = "shortrLink"
}

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "ke-terraform-backends"
    key = "state/startdust/sender_service.dev.tfstate"
    region = "eu-west-1"
    profile = "privateGmail"
  }
}

provider "aws" {
  region = "eu-west-1"
  profile = "privateGmail"
  default_tags {
    tags = {
      terraform = "true"
      project = local.app,
      service = "main"
      stage = local.stage
    }
  }
}

module "dynamodb_table" {
  source   = "../modules/dynamodb"

  app_name = local.app
  stage = local.stage
}

module "timestreamdb" {
  source = "../modules/timestream"

  app_name = local.app
  stage = local.stage
}

resource "aws_cloudwatch_event_bus" "main" {
  name = format("%s_%s_bus", local.app, local.stage)
}

module "cloudfront_s3_website_with_domain" {
  source                 = "../modules/cloudfront-s3-website"
  hosted_zone            = "shortrlink.com"
  domain_name            = "dev.shortrlink.com"
  use_default_domain = true
//  acm_certificate_domain = "*.shortrlink.com"

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

resource "aws_ssm_parameter" "dynamodb_stream_arn" {
  name = format("/%s/%s/dynamodb_stream_arn", local.app,local.stage)
  type = "String"
  value = module.dynamodb_table.stream_arn
}

resource "aws_ssm_parameter" "eventbus_name" {
  name = format("/%s/%s/eventbus_name", local.app,local.stage)
  type = "String"
  value = aws_cloudwatch_event_bus.main.name
}
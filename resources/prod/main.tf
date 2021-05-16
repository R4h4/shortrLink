locals {
  stage = "prod"
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
    key = "state/startdust/sender_service.prod.tfstate"
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
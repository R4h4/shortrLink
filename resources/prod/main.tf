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

module "cognito_user_pool" {
  source = "mineiros-io/cognito-user-pool/aws"
  version = "~> 0.6.0"

  name = "${lower(local.app)}-${local.stage}-userpool"

  # We allow the public to create user profiles
  allow_admin_create_user_only = false

  enable_username_case_sensitivity = false
  advanced_security_mode = "ENFORCED"
  password_minimum_length = 8
  password_require_lowercase = false
  password_require_symbols = false
  password_require_numbers = false
  password_require_uppercase = false

  alias_attributes = [
    "email",
    "preferred_username",
  ]

  auto_verified_attributes = [
    "email"
  ]

  account_recovery_mechanisms = [
    {
      name = "verified_email"
      priority = 1
    }
  ]

  # If invited by an admin
  invite_email_subject = "Welcome to shortrLink"
  invite_email_message = "Hi {username}, your temporary password is '{####}'."
  invite_sms_message = "Hi {username}, your temporary password is '{####}'."

  domain = "${lower(local.app)}-${local.stage}"
  default_email_option = "CONFIRM_WITH_LINK"
  email_subject_by_link = "Your Verification Link for shortrLink"
  email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##}."
  sms_message = "Your verification code is {####}."

  challenge_required_on_new_device = true
  user_device_tracking = "USER_OPT_IN"

  # These paramters can be used to configure SES for emails
  # email_sending_account  = "DEVELOPER"
  # email_reply_to_address = "support@mineiros.io"
  # email_from_address     = "noreply@mineiros.io"
  # email_source_arn       = "arn:aws:ses:us-east-1:999999999999:identity"

  temporary_password_validity_days = 3

  schema_attributes = [
    {
      name = "alternative_name"
      type = "String"
      developer_only_attribute = false,
      mutable = true,
      required = false,
      min_length = 0,
      max_length = 2048
    },
    {
      name = "is_active"
      type = "Boolean"

    },
    {
      name = "last_seen"
      type = "DateTime"
    }
  ]

  clients = [
    {
      name = "web-app-client"
      read_attributes = [
        "email",
        "email_verified",
        "preferred_username"]
      allowed_oauth_scopes = [
        "email",
        "openid"]
      allowed_oauth_flows = [
        "implicit"]
      callback_urls = [
        "https://shortrlink.com/dashboard"]
      default_redirect_uri = "https://shortrlink.com/dashboard"
      generate_secret = false
    }
  ]
}

resource "aws_ssm_parameter" "user_pool_id" {
  name = "/${local.app}/${local.stage}/user_pool_id"
  type = "String"
  value = module.cognito_user_pool.user_pool.id
}

resource "aws_ssm_parameter" "user_client_id_web" {
  name = "/${local.app}/${local.stage}/user_pool_web_client_id"
  type = "String"
  value = module.cognito_user_pool.clients["web-app-client"].id
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

module "cognito_user_pool" {
  source  = "mineiros-io/cognito-user-pool/aws"
  version = "~> 0.6.0"

  name = "${lower(local.app)}-${local.stage}-userpool"

  # We allow the public to create user profiles
  allow_admin_create_user_only = false

  enable_username_case_sensitivity = false
  advanced_security_mode           = "ENFORCED"
  password_minimum_length          = 8
  password_require_lowercase       = false
  password_require_symbols         = false
  password_require_numbers         = false
  password_require_uppercase       = false

  alias_attributes = [
    "email",
    "phone_number",
    "preferred_username",
  ]

  auto_verified_attributes = [
    "email"
  ]

  account_recovery_mechanisms = [
    {
      name     = "verified_email"
      priority = 1
    },
    {
      name     = "verified_phone_number"
      priority = 2
    }
  ]

  # If invited by an admin
  invite_email_subject = "Welcome to shortrLink"
  invite_email_message = "Hi {username}, your temporary password is '{####}'."
  invite_sms_message   = "Hi {username}, your temporary password is '{####}'."

  domain                = "${lower(local.app)}-${local.stage}"
  default_email_option  = "CONFIRM_WITH_LINK"
  email_subject_by_link = "Your Verification Link for shortrLink"
  email_message_by_link = "Please click the link below to verify your email address. {##Verify Email##}."
  sms_message           = "Your verification code is {####}."

  challenge_required_on_new_device = true
  user_device_tracking             = "USER_OPT_IN"

  # These paramters can be used to configure SES for emails
  # email_sending_account  = "DEVELOPER"
  # email_reply_to_address = "support@mineiros.io"
  # email_from_address     = "noreply@mineiros.io"
  # email_source_arn       = "arn:aws:ses:us-east-1:999999999999:identity"

  temporary_password_validity_days = 3

  schema_attributes = [
    {
      name                     = "alternative_name"
      type                     = "String"
      developer_only_attribute = false,
      mutable                  = true,
      required                 = false,
      min_length               = 0,
      max_length               = 2048
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
      generate_secret      = false
    }
  ]
}

resource "aws_ssm_parameter" "user_pool_id" {
  name  = "/${local.app}/${local.stage}/user_pool_id"
  type  = "String"
  value = module.cognito_user_pool.user_pool.id
}

resource "aws_ssm_parameter" "user_client_id_web" {
  name  = "/${local.app}/${local.stage}/user_pool_web_client_id"
  type  = "String"
  value = module.cognito_user_pool.clients["web-app-client"].id
}
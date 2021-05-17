locals {
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
}

resource "aws_dynamodb_table" "main_table" {
  hash_key = "PK"
  range_key = "SK"
  name = format("%s_%s", var.app_name, var.stage)

  billing_mode   = var.billing_mode
  read_capacity  = local.read_capacity
  write_capacity = local.write_capacity

  stream_enabled = var.stream_enabled
  stream_view_type = "KEYS_ONLY"

  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }
}


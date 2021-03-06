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
  stream_view_type = "NEW_AND_OLD_IMAGES"

  global_secondary_index {
    name               = "UserCreatedAtIndex"
    hash_key           = "user"
    range_key          = "createdAt"
    projection_type    = "ALL"
  }

  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }
  attribute {
    name = "user"
    type = "S"
  }
  attribute {
    name = "createdAt"
    type = "S"
  }

  replica {
    region_name = "ap-southeast-1"
  }

  replica {
    region_name = "us-east-1"
  }
}


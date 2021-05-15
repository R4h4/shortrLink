resource "aws_dynamodb_table" "main_table" {
  hash_key = "PK"
  range_key = "SK"
  name = format("s%_%s", var.app_name, var.stage)

  attribute {
    name = "PK"
    type = "S"
  }
  attribute {
    name = "SK"
    type = "S"
  }
}
output "table_name" {
  value = aws_dynamodb_table.main_table.name
}

output "table_arn" {
  value = aws_dynamodb_table.main_table.arn
}

output "stream_arn" {
  value = aws_dynamodb_table.main_table.stream_arn
}

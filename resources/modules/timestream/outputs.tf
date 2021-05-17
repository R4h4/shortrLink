output "database_name" {
  value = aws_timestreamwrite_database.this.database_name
}

output "redirects_table_name" {
  value = aws_timestreamwrite_table.redirects.table_name
}

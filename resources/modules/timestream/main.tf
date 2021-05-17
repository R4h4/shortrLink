resource "aws_timestreamwrite_database" "this" {
  database_name = format("%s_%s", var.app_name, var.stage)
}

resource "aws_timestreamwrite_table" "redirects" {
  database_name = aws_timestreamwrite_database.this.database_name
  table_name    = "redirects"

  retention_properties {
    magnetic_store_retention_period_in_days = 90
    memory_store_retention_period_in_hours  = 24
  }
}
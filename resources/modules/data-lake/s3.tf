resource "aws_s3_bucket" "raw_events" {
  bucket        = lower("${var.app_name}-datalake-raw-${var.stage}")
  acl           = "private"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket" "prepared_events" {
  bucket        = lower("${var.app_name}-datalake-prepared-${var.stage}")
  acl           = "private"
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket" "trusted_events" {
  bucket        = lower("${var.app_name}-datalake-trusted-${var.stage}")
  acl           = "private"
  force_destroy = var.force_destroy
}
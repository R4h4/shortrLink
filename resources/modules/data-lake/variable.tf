variable "stage" {
  description = "Deployment stage"
  type        = string
}

variable "app_name" {
  description = "Name of the app"
  type        = string
}

variable "eventbus_name" {
  description = "The ARN of the central EventBridge Bus"
  type        = string
}

variable "force_destroy" {
  description = "Defines force_destroy for all stages s3 buckets"
  type        = string
  default     = true
}

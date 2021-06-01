variable "stage" {
  description = "Deployment stage"
  type = string
}

variable "app_name" {
  description = "Name of the app"
}

variable "domain_name" {
  description = "domain name (or application name if no domain name available)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "tags for all the resources, if any"
}

variable "hosted_zone" {
  default     = null
  description = "Route53 hosted zone"
}

variable "website_domain_redirect" {
  description = "Additional domain to redict to primary website"
}

variable "acm_certificate_domain" {
  default     = null
  description = "Domain of the ACM certificate"
}

variable "acm_certificate_arn" {
  default     = null
  description = "Arn of the ACM certificate"
}

variable "price_class" {
  default     = "PriceClass_100" // Only US,Canada,Europe
  description = "CloudFront distribution price class"
}

variable "cors_allowed_headers" {
  type        = list(string)
  default     = ["*"]
  description = "List of allowed headers"
}

variable "cors_allowed_methods" {
  type        = list(string)
  default     = ["GET"]
  description = "List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) "
}

variable "cors_allowed_origins" {
  type        = list(string)
  default     = ["*"]
  description = "List of allowed origins (e.g. example.com, test.com)"
}

variable "cors_expose_headers" {
  type        = list(string)
  default     = ["ETag"]
  description = "List of expose header in the response"
}

variable "cors_max_age_seconds" {
  type        = number
  default     = 3600
  description = "Time in seconds that browser can cache the response"
}
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


provider "aws" {
  region = "us-east-1"
  profile = "privateGmail"
  alias  = "aws_cloudfront"
}


data "aws_acm_certificate" "acm_cert" {
  domain   = coalesce(var.acm_certificate_domain, "*.${var.hosted_zone}")

  provider = aws.aws_cloudfront
  //CloudFront uses certificates from US-EAST-1 region only
  statuses = [
    "ISSUED",
  ]
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "1"

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "arn:aws:s3:::${var.domain_name}/*",
    ]

    principals {
      type = "AWS"

      identifiers = [
        aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn,
      ]
    }
  }
}

# Creates bucket to store logs
resource "aws_s3_bucket" "website_logs" {
  bucket = "${var.domain_name}-logs"
  acl    = "log-delivery-write"

  # Comment the following line if you are uncomfortable with Terraform destroying the bucket even if this one is not empty
  force_destroy = true

  lifecycle {
    ignore_changes = [tags["Changed"]]
  }
}

resource "aws_s3_bucket" "website_root" {
  bucket = var.domain_name
  acl    = "private"
  versioning {
    enabled = true
  }
    logging {
    target_bucket = aws_s3_bucket.website_logs.bucket
    target_prefix = "${var.domain_name}/"
  }
  website {
    index_document = "index.html"
    error_document = "404.html"
  }
  policy = data.aws_iam_policy_document.s3_bucket_policy.json
  tags   = var.tags
}

data "aws_route53_zone" "domain_name" {
  name         = var.hosted_zone
  private_zone = false
}

resource "aws_route53_record" "route53_record" {
  depends_on = [
    aws_cloudfront_distribution.s3_distribution
  ]

  zone_id = data.aws_route53_zone.domain_name.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name    = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id = "Z2FDTNDATAQYW2"

    //HardCoded value for CloudFront
    evaluate_target_health = false
  }
}

# Creates bucket for the website handling the redirection (if required), e.g. from https://www.example.com to https://example.com
resource "aws_s3_bucket" "website_redirect" {
  bucket        = "${var.domain_name}-redirect"
  acl           = "public-read"
  force_destroy = true

  logging {
    target_bucket = aws_s3_bucket.website_logs.bucket
    target_prefix = "${var.domain_name}-redirect/"
  }

  website {
    redirect_all_requests_to = "https://${var.domain_name}"
  }

  lifecycle {
    ignore_changes = [tags["Changed"]]
  }
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  depends_on = [
    aws_s3_bucket.website_root
  ]

  origin {
    domain_name = aws_s3_bucket.website_root.website_endpoint
//    origin_id   = "s3-cloudfront"
    origin_id = "origin-bucket-${aws_s3_bucket.website_root.id}"
    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = ["TLSv1.2", "TLSv1.1", "TLSv1"]
    }
//    s3_origin_config {
//      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
//    }

  }

  logging_config {
    bucket = aws_s3_bucket.website_logs.bucket_domain_name
    prefix = "${var.domain_name}/"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
    ]

    cached_methods = [
      "GET",
      "HEAD",
    ]

    target_origin_id = "origin-bucket-${aws_s3_bucket.website_root.id}"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.acm_cert.arn
    ssl_support_method  = "sni-only"
  }
//  dynamic "viewer_certificate" {
//    for_each = local.default_certs
//    content {
//      cloudfront_default_certificate = true
//    }
//  }
//
//  dynamic "viewer_certificate" {
//    for_each = local.acm_certs
//    content {
//      acm_certificate_arn      = data.aws_acm_certificate.acm_cert[0].arn
//      ssl_support_method       = "sni-only"
//      minimum_protocol_version = "TLSv1"
//    }
//  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/"
  }

  wait_for_deployment = false
  tags                = var.tags
}

# Creates policy to allow public access to the S3 bucket
resource "aws_s3_bucket_policy" "update_website_root_bucket_policy" {
  bucket = aws_s3_bucket.website_root.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "PolicyForWebsiteEndpointsPublicContent",
  "Statement": [
    {
      "Sid": "PublicRead",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "${aws_s3_bucket.website_root.arn}/*",
        "${aws_s3_bucket.website_root.arn}"
      ]
    }
  ]
}
POLICY
}

# Creates the CloudFront distribution to serve the redirection website (if redirection is required)
resource "aws_cloudfront_distribution" "website_cdn_redirect" {
  enabled     = true
  price_class = "PriceClass_All"
  # Select the correct PriceClass depending on who the CDN is supposed to serve (https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/PriceClass.html)
  aliases = [var.website_domain_redirect]

  origin {
    origin_id   = "origin-bucket-${aws_s3_bucket.website_redirect.id}"
    domain_name = aws_s3_bucket.website_redirect.website_endpoint

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  logging_config {
    bucket = aws_s3_bucket.website_logs.bucket_domain_name
    prefix = "${var.website_domain_redirect}/"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT", "DELETE"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "origin-bucket-${aws_s3_bucket.website_redirect.id}"
    min_ttl          = "0"
    default_ttl      = "300"
    max_ttl          = "1200"

    viewer_protocol_policy = "redirect-to-https" # Redirects any HTTP request to HTTPS
    compress               = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.acm_cert.arn
    ssl_support_method  = "sni-only"
  }

//  tags = merge(var.tags, {
//    ManagedBy = "terraform"
//    Changed   = formatdate("YYYY-MM-DD hh:mm ZZZ", timestamp())
//  })

  lifecycle {
    ignore_changes = [
      tags["Changed"],
      viewer_certificate,
    ]
  }
}

# Creates the DNS record to point on the CloudFront distribution ID that handles the redirection website
resource "aws_route53_record" "website_cdn_redirect_record" {
  zone_id = data.aws_route53_zone.domain_name.zone_id
  name    = var.website_domain_redirect
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cdn_redirect.domain_name
    zone_id                = aws_cloudfront_distribution.website_cdn_redirect.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${var.domain_name}.s3.amazonaws.com"
}
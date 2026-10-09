// Copyright 2026 Bitshift ED (https://www.bitshifted.com)
# SPDX-License-Identifier: MPL-2.0

resource "aws_cloudfront_origin_access_identity" "this" {
  count = var.enable_cloudfront ? 1 : 0

  comment = "Origin Access Identity for ${var.bucket_name} (${var.environment})"
}

resource "aws_cloudfront_distribution" "this" {
  count = var.enable_cloudfront ? 1 : 0

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  comment             = var.comment != "" ? var.comment : "CloudFront distribution for ${var.bucket_name} (${var.environment})"
  price_class         = var.price_class

  #checkov:skip=CKV2_AWS_47: WAF with AMR is optional; enable web_acl_id variable when WAF is needed
  web_acl_id = var.web_acl_id

  origin {
    origin_id   = "S3-${var.bucket_name}"
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this[0].cloudfront_access_identity_path
    }
  }

  aliases = length(var.custom_domain_names) > 0 ? var.custom_domain_names : []

  viewer_certificate {
    cloudfront_default_certificate = var.ssl_certificate_arn == null
    acm_certificate_arn            = var.ssl_certificate_arn != null ? var.ssl_certificate_arn : ""
    minimum_protocol_version       = var.min_tls_version
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "S3-${var.bucket_name}"
    viewer_protocol_policy = "redirect-to-https"

    compress = true

    forwarded_values {
      query_string = var.forward_query_strings

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    #checkov:skip=CKV2_AWS_32: Response headers policy configured via variable, defaults to security-headers-cors
    response_headers_policy_id = var.response_headers_policy_id
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
    response_code         = "200"
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
    response_code         = "200"
  }

  depends_on = [
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_policy.this
  ]
}

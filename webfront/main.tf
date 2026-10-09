// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

locals {
  access_log_prefix = "access-logs/"

  default_tags = merge({
    Environment = var.environment
    Version     = var.revision
    Module      = "webfront-s3"
  }, var.tags)
}

resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_delete

  tags = local.default_tags

  #checkov:skip=CKV2_AWS_62: Event notifications not needed for static web apps served via CloudFront
  #checkov:skip=CKV_AWS_144: Cross-region replication not needed; CloudFront handles global distribution

  dynamic "cors_rule" {
    for_each = var.enable_cors ? [1] : []
    content {
      allowed_headers = var.cors_allowed_headers
      allowed_methods = var.cors_allowed_methods
      allowed_origins = var.cors_allowed_origins
      expose_headers  = var.cors_expose_headers
      max_age_seconds = var.cors_max_age
    }
  }

  dynamic "logging" {
    for_each = var.enable_access_logging ? [1] : []
    content {
      target_bucket = var.access_logging_bucket_name
      target_prefix = local.access_log_prefix
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn != null ? var.kms_key_arn : null
    }
    bucket_key_enabled = true
  }

  depends_on = [aws_s3_bucket_policy.this]
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      [
        # Deny unencrypted HTTP requests - requires CloudFront to use HTTPS
        {
          Sid       = "EnforceHTTPS"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:GetObject"
          Resource  = "${aws_s3_bucket.this.arn}/*"
          Condition = {
            Bool = {
              "aws:SecureTransport" = "false"
            }
          }
        },
        # Deny requests that don't include explicit KMS encryption header when uploading
        {
          Sid       = "DenyUnencryptedUploads"
          Effect    = "Deny"
          Principal = "*"
          Action    = "s3:PutObject"
          Resource  = "${aws_s3_bucket.this.arn}/*"
          Condition = {
            StringNotEquals = {
              "s3:x-amz-server-side-encryption" = "aws:kms"
            }
          }
        }
      ],
      var.s3_object_lambda_policies != null ? [var.s3_object_lambda_policies] : []
    )
  })
}

resource "aws_s3_bucket_acl" "this" {
  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.enable_versioning ? [1] : []
    content {
      id     = "noncurrent-version-expiration"
      status = "Enabled"

      noncurrent_version_expiration {
        noncurrent_days = var.noncurrent_version_expiration_days
      }

      abort_incomplete_multipart_upload {
        days_after_initiation = var.abort_incomplete_multipart_upload_days
      }
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  #checkov:skip=CKV2_AWS_65: BucketOwnerPreferred is AWS-recommended; enforces no ACL on objects by default
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_object" "index_error" {
  for_each = var.enable_host_error_pages ? {
    for idx, page in var.html_pages :
    lookup(page, "key", "") => page
    if contains(["index.html", "error.html"], lookup(page, "key", ""))
  } : {}

  bucket        = aws_s3_bucket.this.id
  key           = each.value.key
  source        = each.value.source_file
  content_type  = lookup(each.value, "content_type", "text/html; charset=utf-8")
  cache_control = lookup(each.value, "cache_control", "no-cache, no-store, must-revalidate")
  etag          = filemd5(each.value.source_file)

  lifecycle {
    replace_triggered_by = []
  }

  depends_on = [
    aws_s3_bucket.this,
    aws_s3_bucket_public_access_block.this,
    aws_s3_bucket_acl.this,
    aws_s3_bucket_policy.this
  ]
}

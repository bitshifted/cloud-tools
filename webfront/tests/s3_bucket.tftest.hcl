// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

mock_provider "aws" {
}

run "create_bucket_with_basic_config" {
  command = plan

  variables {
    environment = "test"
    revision    = "1.0.0"
    bucket_name = "test-app-bucket"
  }

  assert {
    condition     = var.bucket_name == "test-app-bucket"
    error_message = "Bucket name should match variable"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls == true
    error_message = "Public access block should block public ACLs"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy == true
    error_message = "Public access block should block public policies"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.ignore_public_acls == true
    error_message = "Public access block should ignore public ACLs"
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets == true
    error_message = "Public access block should restrict public buckets"
  }
}

run "enable_versioning_by_default" {
  command = plan

  variables {
    environment = "test"
    revision    = "1.0.0"
    bucket_name = "test-app-bucket-v2"
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should be enabled by default"
  }
}

run "bucket_encryption_uses_kms" {
  command = plan

  variables {
    environment   = "test"
    revision      = "1.0.0"
    bucket_name   = "test-encrypted-bucket"
    kms_key_arn   = "arn:aws:kms:us-east-1:123456789012:key/abcd1234a123456aba1babc12345de"
  }

  assert {
    condition     = length([for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : r if r.apply_server_side_encryption_by_default[0].sse_algorithm == "aws:kms"]) > 0
    error_message = "Encryption should use KMS algorithm"
  }

  assert {
    condition     = length([for r in aws_s3_bucket_server_side_encryption_configuration.this.rule : r if r.bucket_key_enabled == true]) > 0
    error_message = "Bucket key should be enabled for cost optimization"
  }
}

run "deny_https_policy_enforced" {
  command = apply

  variables {
    environment = "test"
    revision    = "1.0.0"
    bucket_name = "test-https-enforcement"
  }

  assert {
    condition     = length(jsondecode(aws_s3_bucket_policy.this.policy).Statement) >= 2
    error_message = "Policy should have at least 2 statements"
  }

  assert {
    condition     = can(regex("false", jsondecode(aws_s3_bucket_policy.this.policy).Statement[0].Condition.Bool["aws:SecureTransport"]))
    error_message = "HTTPS enforcement policy should deny insecure transport"
  }
}

run "disable_versioning_option" {
  command = plan

  variables {
    environment         = "test"
    revision            = "1.0.0"
    bucket_name         = "test-no-versioning"
    enable_versioning   = false
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Suspended"
    error_message = "Versioning should be disabled when enable_versioning is false"
  }
}

run "cloudfront_enabled_creates_resources" {
  command = plan

  variables {
    environment         = "test"
    revision            = "1.0.0"
    bucket_name         = "test-cloudfront-bucket"
    enable_cloudfront   = true
  }

  assert {
    condition     = length(aws_cloudfront_origin_access_identity.this) == 1
    error_message = "Origin Access Identity should be created when CloudFront is enabled"
  }

  assert {
    condition     = length(aws_cloudfront_distribution.this) == 1
    error_message = "Distribution should be created when CloudFront is enabled"
  }
}

run "cloudfront_disabled_no_resources" {
  command = plan

  variables {
    environment         = "test"
    revision            = "1.0.0"
    bucket_name         = "test-no-cloudfront-bucket"
    enable_cloudfront   = false
  }

  assert {
    condition     = length(aws_cloudfront_origin_access_identity.this) == 0
    error_message = "Origin Access Identity should not exist when disabled"
  }

  assert {
    condition     = length(aws_cloudfront_distribution.this) == 0
    error_message = "Distribution should not exist when disabled"
  }
}

run "cloudfront_with_custom_domains" {
  command = plan

  variables {
    environment         = "test"
    revision            = "1.0.0"
    bucket_name         = "test-custom-domain-bucket"
    enable_cloudfront   = true
    custom_domain_names = ["cdn.example.com"]
    ssl_certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abcd1234-a123-456a-a12b-abcd123456ef"
  }

  assert {
    condition     = contains(aws_cloudfront_distribution.this[0].aliases, "cdn.example.com")
    error_message = "Custom domain alias should be configured"
  }

  assert {
    condition     = var.ssl_certificate_arn == aws_cloudfront_distribution.this[0].viewer_certificate[0].acm_certificate_arn
    error_message = "ACM certificate ARN should match input"
  }
}


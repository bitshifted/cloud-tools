// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

output "bucket_id" {
  value       = aws_s3_bucket.this.id
  description = "The name of the S3 bucket."
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "The ARN of the S3 bucket."
}

output "bucket_name" {
  value       = aws_s3_bucket.this.bucket
  description = "The name of the S3 bucket."
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.this.bucket_domain_name
  description = "The bucket domain name in format: bucket-name.s3.amazonaws.com"
}

output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.this.bucket_regional_domain_name
  description = "The bucket region-specific domain name: bucket-name.s3.region-code.amazonaws.com"
}

output "bucket_website_endpoint" {
  value       = aws_s3_bucket.this.website_endpoint
  description = "The website endpoint, if the bucket is configured with a website. Null if not."
}

output "distribution_id" {
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.this[0].id : null
  description = "The ID of the CloudFront distribution."
}

output "distribution_domain_name" {
  value       = var.enable_cloudfront ? aws_cloudfront_distribution.this[0].domain_name : null
  description = "The domain name of the CloudFront distribution."
}

output "origin_access_identity_id" {
  value       = var.enable_cloudfront ? aws_cloudfront_origin_access_identity.this[0].id : null
  description = "The CloudFront Origin Access Identity ID."
}

output "origin_access_identity_iam_arn" {
  value       = var.enable_cloudfront ? aws_cloudfront_origin_access_identity.this[0].iam_arn : null
  description = "The IAM ARN of the Origin Access Identity."
}

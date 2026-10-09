// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

variable "environment" {
  type        = string
  description = "Environment for this Terraform stack (e.g., dev, staging, prod)"
}

variable "revision" {
  type        = string
  description = "Version information for this stack. Should be updated with every change"
}

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket to host web application files"
}

variable "enable_versioning" {
  type        = bool
  default     = true
  description = "Enable versioning on S3 bucket to protect against accidental deletions and modifications"
}

variable "force_delete" {
  type        = bool
  default     = false
  description = "If true, allows destroying the bucket even if it contains objects (useful for development environments)"
}

variable "enable_host_error_pages" {
  type        = bool
  default     = true
  description = "Whether to deploy error pages (index.html and error.html). Required for CloudFront custom error handling."
}

variable "html_pages" {
  type = list(object({
    key           = string
    source_file   = string
    content_type  = optional(string, "text/html; charset=utf-8")
    cache_control = optional(string, "no-cache, no-store, must-revalidate")
  }))
  default     = []
  description = "List of HTML pages to upload. Each entry specifies key (filename), source_file path, and optional metadata."

  validation {
    condition = (
      alltrue([for page in var.html_pages : contains(["index.html", "error.html"], page.key)])
    ) || !var.enable_host_error_pages || length(var.html_pages) == 0
    error_message = "Keys must be either 'index.html' or 'error.html'."
  }

  validation {
    condition     = alltrue([for page in var.html_pages : fileexists(page.source_file)])
    error_message = "All specified source_file paths must exist."
  }
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "ARN of KMS key for S3 server-side encryption. If not provided, uses AWS managed key."

  validation {
    condition     = var.kms_key_arn == null || can(regex("^arn:aws:kms:[a-z0-9-]*:[0-9]*:key\\/[0-9a-f-]+$", var.kms_key_arn))
    error_message = "kms_key_arn must be a valid KMS key ARN."
  }
}

variable "enable_cors" {
  type        = bool
  default     = false
  description = "Whether to enable CORS configuration on the bucket. Enable when accessing from different origins."
}

variable "cors_allowed_headers" {
  type        = list(string)
  default     = ["*"]
  description = "Allowed headers for CORS requests."
}

variable "cors_allowed_methods" {
  type        = list(string)
  default     = ["GET", "HEAD", "PUT", "POST", "DELETE"]
  description = "Allowed HTTP methods for CORS requests."
}

variable "cors_allowed_origins" {
  type        = list(string)
  default     = []
  description = "Allowed origins for CORS requests."
}

variable "cors_expose_headers" {
  type        = list(string)
  default     = []
  description = "Headers exposed to browser for CORS responses."
}

variable "cors_max_age" {
  type        = number
  default     = 3600
  description = "Duration in seconds that browser caches CORS preflight response results."
}

variable "enable_access_logging" {
  type        = bool
  default     = false
  description = "Enable access logging for S3 bucket. Requires access_logging_bucket_name to be set."
}

variable "access_logging_bucket_name" {
  type        = string
  default     = null
  description = "Name of target bucket for access logs. Required when enable_access_logging is true."

  validation {
    condition     = var.enable_access_logging ? var.access_logging_bucket_name != null && can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.access_logging_bucket_name)) : true
    error_message = "access_logging_bucket_name must be a valid S3 bucket name when enable_access_logging is true."
  }
}

variable "noncurrent_version_expiration_days" {
  type        = number
  default     = 90
  description = "Number of days after which expired noncurrent versions are deleted. Must be positive integer."

  validation {
    condition     = var.noncurrent_version_expiration_days > 0
    error_message = "noncurrent_version_expiration_days must be greater than zero."
  }
}

variable "abort_incomplete_multipart_upload_days" {
  type        = number
  default     = 7
  description = "Number of days after which to abort incomplete multipart uploads. Must be a positive integer."

  validation {
    condition     = var.abort_incomplete_multipart_upload_days > 0
    error_message = "abort_incomplete_multipart_upload_days must be greater than zero."
  }
}

variable "s3_object_lambda_policies" {
  type        = string
  default     = null
  description = "Optional JSON policy document for S3 Object Lambda integration."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to all resources created by this module"
}

variable "enable_cloudfront" {
  type        = bool
  default     = false
  description = "Enable CloudFront distribution creation. Set to true when using CloudFront to serve content."
}

variable "price_class" {
  type        = string
  default     = "PriceClass_200"
  description = "CloudFront price class. Options: PriceClass_100 (US only), PriceClass_200 (US+Europe), PriceClass_All (Global)."

  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.price_class)
    error_message = "price_class must be one of: PriceClass_100, PriceClass_200, or PriceClass_All"
  }
}

variable "comment" {
  type        = string
  default     = ""
  description = "Comment for the CloudFront distribution."
}

variable "min_tls_version" {
  type        = string
  default     = "TLSv1.2_2021"
  description = "Minimum TLS version for viewer HTTPS connections."

  validation {
    condition     = contains(["TLSv1.2_2019", "TLSv1.2_2021", "TLSv1.2_2018", "TLSv1.1_2016"], var.min_tls_version)
    error_message = "min_tls_version must be a valid TLS version string."
  }
}

variable "custom_domain_names" {
  type        = list(string)
  default     = []
  description = "CNAMEs (alternate domain names) for the CloudFront distribution. Requires ssl_certificate_arn."
}

variable "ssl_certificate_arn" {
  type        = string
  default     = null
  description = "ACM certificate ARN in us-east-1 for custom domain names. Required when custom_domain_names is set."

  validation {
    condition     = var.ssl_certificate_arn == null || can(regex("^arn:aws:acm:[a-z0-9-]*:[0-9]*:certificate\\/[0-9a-f-]+$", var.ssl_certificate_arn))
    error_message = "ssl_certificate_arn must be a valid ACM certificate ARN."
  }
}

variable "forward_query_strings" {
  type        = bool
  default     = false
  description = "Whether to forward query strings to S3 origin in default cache behavior."
}

variable "response_headers_policy_id" {
  type        = string
  default     = "67f77653-9e47-4d66-a105-70da5fcff96e"
  description = "Response headers policy ID to attach to the CloudFront distribution (e.g., security-headers-cors or AWS managed policy IDs). Defaults to AWS managed security-headers-cors policy."
}

variable "web_acl_id" {
  type        = string
  default     = null
  description = "WAF Web ACL ARN to associate with the CloudFront distribution."
}

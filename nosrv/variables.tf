# Copyright 2026 Bitshift ED (https://www.bitshifted.com)


variable "environment" {
  type        = string
  description = "Environment for this Terraform stack (e.g., dev, staging, prod)"
}

variable "revision" {
  type        = string
  description = "Version information for this stack. Should be updated with every change"
}


variable "lambda_defs" {
  type = map(object({
    function_name         = string
    handler               = string
    runtime               = string
    execution_role_arn    = optional(string, null)
    execution_role_policy = optional(string, null)
    memory                = optional(number, 128)
    timeout               = optional(number, 10)
    xray_tracing_mode     = optional(string, "Active")
    zip_archive_config = optional(object({
      source_file = optional(string, null)
      source_dir  = optional(string, null)
      output_dir  = string
    }), null)
    code_signing_config_arn = optional(string, null)
    concurrency_level       = optional(number, null)
    dlq_arn                 = optional(string, null)
    vpc_config = optional(object({
      subnet_ids         = list(string)
      security_group_ids = list(string)
      ipv6_allowed       = optional(bool, false)
    }), null)
    environment_variables = optional(map(string), {})
    encryption_key_alias  = optional(string, null)
  }))
  default     = {}
  description = "Map of Lambda function definitions. Defaults to empty map."

  validation {
    condition = alltrue([
      for lambda_def in values(var.lambda_defs) : (
        (lambda_def.execution_role_arn == null && lambda_def.execution_role_policy != null) ||
        (lambda_def.execution_role_arn != null && lambda_def.execution_role_policy == null)
      )
    ])
    error_message = "One of `execution_role_arn` or `execution_role_policy` must be provided, but not both."
  }

  validation {
    condition = alltrue([
      for lambda_def in values(var.lambda_defs) : (
        !can(regex("^java[0-9]+(\\.al2)?$", lambda_def.runtime)) ||
        (lambda_def.zip_archive_config != null && lambda_def.zip_archive_config.source_file != null)
      )
    ])
    error_message = "For Java runtimes, `zip_archive_config` must be provided and `source_file` must be set to the path of the JAR file."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to all created resources"
}

variable "dlq_name" {
  type        = string
  default     = "sqs-shared-dlq"
  description = "Name of the shared SQS DLQ."
}

variable "sqs_kms_key_alias" {
  type        = string
  default     = null
  description = "Alias of the KMS key to use for SQS encryption. Defaults to AWS managed key if not provided."
}

variable "sqs_defs" {
  type = map(object({
    name                       = string
    is_fifo                    = optional(bool, false)
    use_dlq                    = optional(bool, true)
    visibility_timeout_seconds = optional(number, 30)
    message_retention_seconds  = optional(number, 345600)
    max_receive_count          = optional(number, 5)
  }))
  default     = {}
  description = "Map of SQS queue definitions. Suffixes with environment and associates with shared DLQ by default."
}

variable "enable_api_gateway" {
  type        = bool
  default     = false
  description = "Whether to create the API Gateway resources."
}

variable "api_name" {
  type        = string
  default     = null
  description = "Base name for the API Gateway. Required if `enable_api_gateway` is true."
  validation {
    condition     = var.api_name == null || can(regex("^[a-zA-Z0-9-]+$", var.api_name))
    error_message = "Invalid API name"
  }
}

variable "openapi_spec_path" {
  type        = string
  default     = null
  description = "Path to the OpenAPI 3.x specification in YAML format. Use $${lambda_key} for Lambda ARNs."
}

variable "enable_api_logging" {
  type        = bool
  default     = true
  description = "Enable CloudWatch access logging for the API Stage."
}

variable "api_log_retention" {
  type        = number
  default     = 7
  description = "Retention in days for API access logs."
}

variable "lambda_log_retention" {
  type        = number
  default     = 7
  description = "Retention in days for Lambda CloudWatch Log Groups. Defaults to 7 days."
}

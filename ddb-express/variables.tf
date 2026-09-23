# Copyright 2026 Bitshift ED (https://www.bitshifted.com)

variable "environment" {
  type        = string
  description = "Environment for this Terraform configuration (ie. dev, prod, staging)"
}

variable "revision" {
  type        = string
  description = "Version information for this stack. Should be updated with every chang"
}

variable "table_name" {
  type        = string
  description = "Name of DynamoDB table"
}

variable "attributes" {
  type = list(object({
    attr_name = string
    attr_type = string
  }))

  validation {
    condition = alltrue([
      for attr in var.attributes : contains(["S", "N", "B"], attr.attr_type)
    ])
    error_message = "Attribute type must be one of S, N, or B."
  }
}

variable "hash_key_attribute" {
  type        = string
  description = "Name of the attribute used as table hash key"

  validation {
    condition     = contains([for attr in var.attributes : attr.attr_name], var.hash_key_attribute)
    error_message = "Hash key attribute must be defined in the attributes list."
  }
}

variable "range_key_attribute" {
  type        = string
  default     = null
  description = "Name of the attribute used as table range key (optional)"

  validation {
    condition     = var.range_key_attribute == null || contains([for attr in var.attributes : attr.attr_name], var.range_key_attribute)
    error_message = "Range key attribute must be defined in the attributes list."
  }
}

variable "gsi_list" {
  type = list(object({
    name            = string
    hash_key        = string
    projection_type = optional(string, "ALL")
    range_key       = optional(string, null)
  }))
  default     = []
  description = "Global secondary indexes configuration"
}

variable "lsi_list" {
  type = list(object({
    name               = string
    range_key          = string
    projection_type    = optional(string, "ALL")
    non_key_attributes = optional(list(string), [])
  }))
  default     = []
  description = "Local secondary indexes configuration"

  validation {
    condition     = length(var.lsi_list) <= 5
    error_message = "A table can have a maximum of 5 local secondary indexes."
  }

  validation {
    condition     = length(var.lsi_list) == 0 || var.range_key_attribute != null
    error_message = "A table must have a primary sort key (range_key_attribute) to support local secondary indexes."
  }
}

variable "point_in_time_recovery_enabled" {
  type        = bool
  default     = true
  description = "Enables point in time recovery (deault 'true')"
}

variable "recovery_period" {
  type        = number
  default     = 35
  description = "Number of days to retain recovery points (default 35)"
}

variable "ttl_attribute" {
  type        = string
  default     = null
  description = "Name of the attribute used for Time to Live (TTL) settings. If set, enables TTL on the table."
}

variable "encryption_key_arn" {
  type        = string
  default     = null
  description = "ARN of KMS key used to encrypt table"
  validation {
    condition     = var.encryption_key_arn == null || can(regex("^arn:(aws|aws-cn|aws-us-gov):kms:[a-z0-9-]+:[0-9]{12}:key/[0-9a-fA-F-]+$", var.encryption_key_arn))
    error_message = "Must be a valid KMS key ARN, such as arn:aws:kms:region:account-id:key/key-id."
  }
}

variable "use_cmk_kms_key" {
  type        = bool
  default     = true
  description = <<-EOT
    Whether to use a customer-managed KMS key for encryption. If `true` (default):
      * key specified in `encryption_key_arn` will be used
      * if `encryption_key_arn` is not set, new key will be created. 
    If varaible is  `false`, the default AWS-managed KMS key for DynamoDB will be used.
  EOT
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to resources"
}

variable "authorized_kms_principals" {
  type        = list(string)
  default     = []
  description = "List of IAM principal ARNs authorized to use the KMS key for cryptographic operations."
}

variable "stream_view_type" {
  type        = string
  default     = null
  description = "DynamoDB stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  validation {
    condition     = var.stream_view_type == null || contains(["KEYS_ONLY", "NEW_IMAGE", "OLD_IMAGE", "NEW_AND_OLD_IMAGES"], var.stream_view_type)
    error_message = "Stream view type must be one of KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, or NEW_AND_OLD_IMAGES."
  }
}

variable "enable_delete_protection" {
  type        = bool
  default     = true
  description = "Enables deletion protection on table. Deafults to true."
}

variable "capacity_config" {
  type = object({
    billing_mode   = optional(string, "PAY_PER_REQUEST")
    table_class    = optional(string, "STANDARD")
    read_capacity  = optional(number, null)
    write_capacity = optional(number, null)
    on_demand_throughput = optional(object({
      max_read_request_units  = optional(number, null)
      max_write_request_units = optional(number, null)
    }), null)
    warm_throughput = optional(object({
      read_units_per_second  = optional(number, null)
      write_units_per_second = optional(number, null)
    }), null)
  })
  default     = {}
  description = "Consolidated capacity and billing configuration for the DynamoDB table."

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.capacity_config.billing_mode)
    error_message = "Billing mode must be either PROVISIONED or PAY_PER_REQUEST."
  }

  validation {
    condition     = contains(["STANDARD", "STANDARD_INFREQUENT_ACCESS"], var.capacity_config.table_class)
    error_message = "Table class must be either STANDARD or STANDARD_INFREQUENT_ACCESS."
  }
}

variable "auto_scaling_config" {
  type = object({
    enabled = optional(bool, true)
    read_config = optional(object({
      min_capacity = optional(number, 25)
      max_capacity = optional(number, 100)
    }), {})
    write_config = optional(object({
      min_capacity = optional(number, 25)
      max_capacity = optional(number, 100)
    }), {})
  })
  default     = {}
  description = "Table auto scaling configuration. Used only if capacity mode is `PROVISIONED`"
}

variable "seed_data_file_path" {
  type        = string
  default     = null
  description = "Path to the file containing seed data to initialize database. File should be in valid DynamoDB JSON format"
}

variable "aws_cli_command" {
  type        = string
  default     = "aws"
  description = "Name of AWS CLI command (defaults to 'aws'). Usefull when you use local setup with tools like 'awslocal'm"
}

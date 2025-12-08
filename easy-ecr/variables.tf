# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0


variable "repository_name" {
  type        = string
  description = "Name of the repository"
}

variable "repo_region" {
  type        = string
  default     = null
  description = "Region in which repositories will be managed. If not specified, defaults to region configured for provider"
}

variable "visibility" {
  type        = string
  description = "Visibility of the repository. Allowed values are 'PRIVATE' (default) and 'PUBLIC'."
  default     = "PRIVATE"

  validation {
    condition     = contains(["PRIVATE", "PUBLIC"], var.visibility)
    error_message = "visibility must be either 'PRIVATE' or 'PUBLIC'."
  }
}

variable "force_delete" {
  type        = bool
  description = "If 'true', deletes repository even if it has contents"
  default     = false
}


variable "use_default_ecnryption_key" {
  type        = bool
  default     = true
  description = "Whether to use default  ECR encryption key (defaults to true)"
}

variable "encryption_key_arn" {
  type        = string
  default     = null
  description = "ARN of KMS key used for repository encryption. If not specified, and use_default_ecnryption_key is false, creates new KMS key"

  validation {
    # If a value is provided for encryption_key_arn, it must be a valid KMS key ARN.
    condition     = (var.use_default_ecnryption_key == false && var.encryption_key_arn != null) ? can(regex("^arn:aws:kms:[a-z0-9-]*:[0-9]*:key\\/[0-9a-z-]+$", var.encryption_key_arn)) : true
    error_message = "If provided, encryption_key_arn must be a valid KMS key ARN."
  }
}

variable "domain_encryption_key_policy_path" {
  type        = string
  default     = null
  description = " Local path to policy file to be applied to created KMS key. If not specified, no custom policy is applied."
}

variable "image_tag_mutable" {
  type        = bool
  default     = true
  description = "Whether image tags are mutable. Only applicable for private repositories."
}

variable "mutability_exclusion_filters" {
  type        = list(string)
  default     = []
  description = "List of tag prefixes to exclude from image tag mutability. Setting this will result in IMMUTABLE_WITH_EXLUSIONSo MUTABLE_WITH_EXCLUSION behavior. Only applicable for private repositories."
}

variable "scan_images_on_push" {
  type        = bool
  default     = true
  description = "Whether images are scanned after being pushed to the repository (true) or not scanned (false). Default is true."
}

variable "public_catalog_data" {
  type = object({
    about             = optional(string, ""),
    description       = optional(string, ""),
    architectures     = optional(list(string), []),
    operating_systems = optional(list(string), []),
    usage             = optional(string, ""),
    logo_image_path   = optional(string, null)
  })
  default     = {}
  description = "Catalog data for public repositories (optional)"

  validation {
    condition     = length(var.public_catalog_data.architectures) == 0 || length([for a in var.public_catalog_data.architectures : a if contains(["ARM", "x86", "ARM 64", "x86-64"], a)]) == length(var.public_catalog_data.architectures)
    error_message = "Allowed values for architecture: 'ARM', 'ARM 64', 'x86', 'x86-64'"
  }

  validation {
    condition     = length(var.public_catalog_data.operating_systems) == 0 || length([for a in var.public_catalog_data.operating_systems : a if contains(["Windows", "Linux"], a)]) == length(var.public_catalog_data.operating_systems)
    error_message = "Allowed values for operating system: 'Windows', 'Linux'"
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to resources"
}

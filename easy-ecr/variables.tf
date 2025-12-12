# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0


variable "repository_name" {
  type        = string
  description = "Name of the repository"
}

variable "ecr_region" {
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

variable "registry_policy_path" {
  type        = string
  default     = null
  description = "Path to JSON policy file (optional). If specified, policy will be applied to registry"
}

variable "repo_policy_path" {
  type        = string
  default     = null
  description = "Path to JSON policy file (optional). If specified, policy will be applied to repository"
}

variable "public_repo_policy_path" {
  type        = string
  default     = null
  description = "Path to JSON policy file (optional). If specified, policy will be applied to public repository."
}

variable "image_lifecycle_policy_path" {
  type        = string
  default     = null
  description = "Path to JSON  file providing lifecycle policy for the repository"
}

variable "use_default_image_lifecycle_policy" {
  type        = bool
  default     = true
  description = "Whether to use default image lifecycle or not. Defaults to true."
}

variable "aws_public_pullthrough_cache_rule" {
  type = object({
    enabled                    = optional(bool, false)
    ecr_repository_prefix      = optional(string, "ROOT")
    upstream_repository_prefix = optional(string, "ROOT")
  })
  default     = {}
  description = "Pullthrough cache rule for AWS public registry. Override default values to customize"
}

variable "k8s_pullthrough_cache_rule" {
  type = object({
    enabled                    = optional(bool, false)
    ecr_repository_prefix      = optional(string, "ROOT")
    upstream_repository_prefix = optional(string, "ROOT")
  })
  default     = {}
  description = "Pullthrough cache rule for Kubernetes public registry. Override default values to customize"
}

variable "quay_pullthrough_cache_rule" {
  type = object({
    enabled                    = optional(bool, false)
    ecr_repository_prefix      = optional(string, "ROOT")
    upstream_repository_prefix = optional(string, "ROOT")
  })
  default     = {}
  description = "Pullthrough cache rule for Quay public registry. Override default values to customize"
}

variable "docker_hub_pullthrough_cache_rule" {
  type = object({
    enabled                    = optional(bool, false)
    ecr_repository_prefix      = optional(string, "ROOT")
    upstream_repository_prefix = optional(string, "ROOT")
    credential_arn             = optional(string, null)
  })
  default     = {}
  description = "Pullthrough cache rule for Docker Hub  registry. Override default values to customize"
}

variable "github_cr_pullthrough_cache_rule" {
  type = object({
    enabled                    = optional(bool, false)
    ecr_repository_prefix      = optional(string, "ROOT")
    upstream_repository_prefix = optional(string, "ROOT")
    credential_arn             = optional(string, null)
  })
  default     = {}
  description = "Pullthrough cache rule for Github Container  registry. Override default values to customize"
}

variable "gitlab_cr_pullthrough_cache_rule" {
  type = object({
    enabled                    = optional(bool, false)
    ecr_repository_prefix      = optional(string, "ROOT")
    upstream_repository_prefix = optional(string, "ROOT")
    credential_arn             = optional(string, null)
  })
  default     = {}
  description = "Pullthrough cache rule for Gitlab Container  registry. Override default values to customize"
}

variable "pullthrough_cache_rules" {
  type = list(object({
    ecr_repository_prefix      = optional(string, "ROOT")
    upstream_repository_prefix = optional(string, "ROOT")
    credential_arn             = optional(string, null)
    custom_role_arn            = optional(string, null)
    upstream_registry_url      = string
  }))
  default     = []
  description = "List of custom pullthrough cache rules to apply to repository"
}

variable "default_account_scan_config" {
  type = object({
    name  = string
    value = string
  })
  default = {
    name  = "BASIC_SCAN_TYPE_VERSION"
    value = "AWS_NATIVE"
  }
  description = "Default ECR basic scan type configuration."
}

variable "registry_scan_configuration" {
  type = object({
    type = optional(string, "BASIC")
    rules = optional(list(object({
      frequency = optional(string, "SCAN_ON_PUSH")
      filter    = optional(string, "*")
    })), [])
  })
  default     = {}
  description = "Registry scanning configuration"
}

variable "replication_config" {
  type = list(object({
    region = string
    filter = optional(string, null)
  }))
  default     = []
  description = "Registry replication configuration"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to resources"
}

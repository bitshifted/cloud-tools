# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

variable "domain_name" {
  type        = string
  description = "Domain name of the repository"
}

variable "repo_region" {
  type        = string
  default     = null
  description = "Region in which repository will be managed. If not specified, defaults to region configured for provider"
}

variable "use_default_ecnryption_key" {
  type        = bool
  default     = true
  description = "Whether to use default  Codeartifact KMS key (defaults to true)"
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

variable "domain_policy_document_path" {
  type        = string
  description = "Path to IAM policy document applied to Codeartifact domain"
  default     = null
}

variable "domain_owner" {
  type        = string
  description = "Account number of the account that owns the repository. If not set, defaults to the account running Terraform"
  default     = null
}

variable "domain_permissions_policy_revision" {
  type        = string
  description = "Current revision of the domain permission policy to set"
  default     = null
}

variable "repositories" {
  type = list(object({
    repository_name                 = string
    description                     = optional(string, "")
    region                          = optional(string, null)
    domain_owner                    = optional(string, null)
    upstream                        = optional(string, null)
    external_connection             = optional(string, null)
    policy_document_path            = optional(string, null)
    default_read_access_principals  = optional(list(string), null)
    default_write_access_principals = optional(list(string), null)
  }))
  description = "List of repositories within Codeartifact domain"
  default     = []

  validation {
    condition = alltrue([
      for repo in var.repositories :
      repo.external_connection == null || contains([
        "public:maven-clojars",
        "public:maven-commonsware",
        "public:maven-googleandroid",
        "public:maven-gradleplugins",
        "public:maven-central",
        "public:npmjs",
        "public:nuget-org",
        "public:pypi",
        "public:ruby-gems-org",
        "public:crates-io"
      ], repo.external_connection)
    ])
    error_message = "Allowed values for external_connection are public:maven-clojars, public:maven-commonsware, public:maven-googleandroid, public:maven-gradleplugins, public:maven-central, public:npmjs, public:nuget-org, public:pypi, public:ruby-gems-org, or public:crates-io."
  }
}

variable "domain_encryption_key_policy_path" {
  type        = string
  description = "Path to file containing IAM policy to be applied to created encryption key"
  default     = null
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to be applied to resources"
}

# Copyright 2026 Bitshift ED (https://www.bitshifted.com)


locals {
  default_tags = {
    Environment = var.environment
    Version     = var.revision
  }

  merged_tags = merge(local.default_tags, var.tags)

  # Regex to identify Java runtimes (e.g., java8, java11, java17, java21)
  java_runtime_regex = "^java[0-9]+(\\.al2)?$"
}


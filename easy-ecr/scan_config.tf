# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0


# Configures default registry scan setting. By default, `BASIC` scan type is used wit `AWS_NATIVE` configuration.
resource "aws_ecr_account_setting" "account_scan_config" {
  name  = var.default_account_scan_config.name
  value = var.default_account_scan_config.value
}

# Configures registry scanning configuration.
resource "aws_ecr_registry_scanning_configuration" "registry_scan_config" {
  region    = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  scan_type = var.registry_scan_configuration.type
  dynamic "rule" {
    for_each = var.registry_scan_configuration.rules
    content {
      scan_frequency = rule.value.frequency
      repository_filter {
        filter      = rule.value.filter
        filter_type = "WILDCARD"
      }
    }
  }
}

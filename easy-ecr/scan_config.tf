# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0


resource "aws_ecr_account_setting" "account_scan_config" {
  name  = var.default_account_scan_config.name
  value = var.default_account_scan_config.value
}
# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0



data "aws_caller_identity" "current" {}

# Defines registry replication configuration. Current implementation allows only replication 
# withing the same AWS account. It is possible to define rul;e filters for replication.
resource "aws_ecr_replication_configuration" "replication_config" {
  count  = length(var.replication_config) > 0 ? 1 : 0
  region = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  replication_configuration {
    rule {
      dynamic "destination" {
        for_each = var.replication_config
        content {
          region      = destination.value.region
          registry_id = data.aws_caller_identity.current.account_id
        }
      }
      dynamic "repository_filter" {
        for_each = [for r in var.replication_config : r if r.filter != null]
        content {
          filter      = repository_filter.value.filter
          filter_type = "PREFIX_MATCH"
        }
      }
    }
  }
}
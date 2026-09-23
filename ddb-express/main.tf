# Copyright 2026 Bitshift ED (https://www.bitshifted.com)

data "aws_caller_identity" "current" {}

locals {
  default_tags = {
    Environment = var.environment
    Version     = var.revision
  }

  merged_tags = merge(local.default_tags, var.tags)

  # final_capacity_config = {
  #   billing_mode         = var.capacity_config.billing_mode
  #   table_class          = var.capacity_config.table_class
  #   read_capacity        = var.capacity_config.billing_mode == "PROVISIONED" ? coalesce(var.capacity_config.read_capacity, 1) : null
  #   write_capacity       = var.capacity_config.billing_mode == "PROVISIONED" ? coalesce(var.capacity_config.write_capacity, 1) : null
  #   on_demand_throughput = var.capacity_config.on_demand_throughput
  #   warm_throughput      = var.capacity_config.warm_throughput
  # }
}

data "aws_iam_policy_document" "kms_key_policy" {
  count = var.use_cmk_kms_key && var.encryption_key_arn == null ? 1 : 0

  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = [
      "kms:*",
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "Allow DynamoDB Service Access"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]
    principals {
      type        = "Service"
      identifiers = ["dynamodb.amazonaws.com"]
    }
  }

  dynamic "statement" {
    for_each = length(var.authorized_kms_principals) > 0 ? [1] : []
    content {
      sid    = "Allow Usage for Authorized Principals"
      effect = "Allow"
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey",
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = var.authorized_kms_principals
      }
    }
  }
}

# Encryption key for the table. Only created if encryption_key_arn variable is not provided, and CMK usage is enabled
resource "aws_kms_key" "db_encryption_key" {
  count                   = var.use_cmk_kms_key && var.encryption_key_arn == null ? 1 : 0
  description             = "DynamoDB encryption key for ${var.table_name}-${var.environment} table"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  policy                  = can(jsondecode(data.aws_iam_policy_document.kms_key_policy[0].json)) ? data.aws_iam_policy_document.kms_key_policy[0].json : null
  tags                    = local.merged_tags
}

# Alias for the created KMS key to make it easier to reference in the DynamoDB table resource. Only created if encryption_key_arn variable is not provided
resource "aws_kms_alias" "db_encryption_key_alias" {
  count         = var.use_cmk_kms_key && var.encryption_key_arn == null ? 1 : 0
  name          = "alias/ddb-${var.table_name}-${var.environment}"
  target_key_id = aws_kms_key.db_encryption_key[0].key_id
}

# Dynamo DB table to create
resource "aws_dynamodb_table" "db_table" {
  # checkov:skip=CKV2_AWS_16: False positive, auto scaling configuration that is defined in separate resources
  name         = "${var.table_name}-${var.environment}"
  billing_mode = var.capacity_config.billing_mode
  table_class  = var.capacity_config.table_class


  read_capacity  = var.capacity_config.billing_mode == "PROVISIONED" ? coalesce(var.capacity_config.read_capacity, 1) : null
  write_capacity = var.capacity_config.billing_mode == "PROVISIONED" ? coalesce(var.capacity_config.write_capacity, 1) : null

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.attr_name
      type = attribute.value.attr_type
    }
  }

  ttl {
    attribute_name = var.ttl_attribute
    enabled        = var.ttl_attribute != null
  }

  hash_key  = var.hash_key_attribute
  range_key = var.range_key_attribute

  dynamic "global_secondary_index" {
    for_each = var.gsi_list
    content {
      name = global_secondary_index.value.name
      key_schema {
        attribute_name = global_secondary_index.value.hash_key
        key_type       = "HASH"
      }
      key_schema {
        attribute_name = global_secondary_index.value.range_key
        key_type       = "RANGE"
      }
      projection_type = global_secondary_index.value.projection_type
    }
  }

  point_in_time_recovery {
    enabled                 = var.point_in_time_recovery_enabled
    recovery_period_in_days = var.recovery_period
  }

  dynamic "local_secondary_index" {
    for_each = var.lsi_list
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = local_secondary_index.value.projection_type
      non_key_attributes = local_secondary_index.value.projection_type == "INCLUDE" ? local_secondary_index.value.non_key_attributes : null
    }
  }

  dynamic "server_side_encryption" {
    for_each = var.use_cmk_kms_key ? [1] : []
    content {
      enabled     = true
      kms_key_arn = var.encryption_key_arn == null ? aws_kms_key.db_encryption_key[0].arn : var.encryption_key_arn
    }
  }

  stream_enabled              = var.stream_view_type != null
  stream_view_type            = var.stream_view_type
  deletion_protection_enabled = var.enable_delete_protection

  dynamic "on_demand_throughput" {
    for_each = var.capacity_config.on_demand_throughput[*]
    content {
      max_read_request_units  = on_demand_throughput.value.max_read_request_units
      max_write_request_units = on_demand_throughput.value.max_write_request_units
    }
  }

  dynamic "warm_throughput" {
    for_each = var.capacity_config.warm_throughput[*]
    content {
      read_units_per_second  = warm_throughput.value.read_units_per_second
      write_units_per_second = warm_throughput.value.write_units_per_second
    }
  }

  tags = local.merged_tags
}


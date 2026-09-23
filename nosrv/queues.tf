# Copyright 2026 Bitshift ED (https://www.bitshifted.com)

# SQS resource definitions for the nosrv module.

locals {
  # Determine if we need to create a shared DLQ
  create_shared_dlq = anytrue([for q in var.sqs_defs : q.use_dlq])

  # Shared DLQ name
  shared_dlq_name = "${var.dlq_name}-${var.environment}"

  # KMS key to use for SQS encryption
  sqs_kms_key_id = var.sqs_kms_key_alias != null ? var.sqs_kms_key_alias : "alias/aws/sqs"

  sqs_tags = local.merged_tags
}

# Shared Dead Letter Queue for all SQS queues in this module instance.
resource "aws_sqs_queue" "shared_dlq" {
  count = local.create_shared_dlq ? 1 : 0

  name = local.shared_dlq_name

  #checkov:skip=CKV2_AWS_73: Using AWS managed key as per design decision or custom alias
  kms_master_key_id = local.sqs_kms_key_id

  tags = local.sqs_tags
}

# Main SQS queues defined in sqs_defs.
resource "aws_sqs_queue" "main" {
  for_each = var.sqs_defs

  name       = "${each.value.name}-${var.environment}"
  fifo_queue = each.value.is_fifo

  visibility_timeout_seconds = each.value.visibility_timeout_seconds
  message_retention_seconds  = each.value.message_retention_seconds

  redrive_policy = each.value.use_dlq ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.shared_dlq[0].arn
    maxReceiveCount     = each.value.max_receive_count
  }) : null

  kms_master_key_id = local.sqs_kms_key_id

  tags = local.sqs_tags
}

# Redrive allow policy for the shared DLQ.
resource "aws_sqs_queue_redrive_allow_policy" "shared_dlq" {
  count = local.create_shared_dlq ? 1 : 0

  queue_url = aws_sqs_queue.shared_dlq[0].id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [for k, v in aws_sqs_queue.main : v.arn if var.sqs_defs[k].use_dlq]
  })
}

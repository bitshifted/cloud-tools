# Copyright 2026 Bitshift ED (https://www.bitshifted.com)



data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  for_each = { for key, lambda_def in var.lambda_defs : key => lambda_def if lambda_def.execution_role_policy != null }

  name               = "${each.value.function_name}-${var.environment}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

resource "aws_iam_policy" "lambda_execution_policy" {
  for_each = { for key, lambda_def in var.lambda_defs : key => lambda_def if lambda_def.execution_role_policy != null }
  name     = "${each.value.function_name}-${var.environment}-exec-policy"
  policy   = each.value.execution_role_policy
}

resource "aws_iam_role_policy_attachment" "lambda_exec_policy" {
  for_each = { for key, lambda_def in var.lambda_defs : key => lambda_def if lambda_def.execution_role_policy != null }

  role       = aws_iam_role.lambda_exec_role[each.key].name
  policy_arn = aws_iam_policy.lambda_execution_policy[each.key].arn
}

data "archive_file" "lambda_zip" {
  for_each    = var.lambda_defs
  type        = "zip"
  source_file = each.value.zip_archive_config != null && each.value.zip_archive_config.source_file != null ? each.value.zip_archive_config.source_file : null
  source_dir  = each.value.zip_archive_config != null && each.value.zip_archive_config.source_dir != null ? each.value.zip_archive_config.source_dir : null
  output_path = "${each.value.zip_archive_config.output_dir}/${each.key}.zip"
}

data "aws_kms_key" "lambda_encryption_key" {
  for_each = { for key, lambda_def in var.lambda_defs : key => lambda_def if lambda_def.encryption_key_alias != null }
  key_id   = each.value.encryption_key_alias
}

resource "aws_lambda_function" "lambda_function" {
  for_each      = var.lambda_defs
  function_name = "${each.value.function_name}-${var.environment}"
  handler       = each.value.handler
  runtime       = each.value.runtime
  role          = each.value.execution_role_arn != null ? each.value.execution_role_arn : aws_iam_role.lambda_exec_role[each.key].arn

  memory_size = each.value.memory
  timeout     = each.value.timeout

  filename         = can(regex(local.java_runtime_regex, each.value.runtime)) ? each.value.zip_archive_config.source_file : data.archive_file.lambda_zip[each.key].output_path
  source_code_hash = can(regex(local.java_runtime_regex, each.value.runtime)) ? filebase64sha256(each.value.zip_archive_config.source_file) : data.archive_file.lambda_zip[each.key].output_base64sha256

  #checkov:skip=CKV_AWS_50: X-Ray tracing is enabled for Lambda
  # Checkov reports this as false positive, so disabling it
  dynamic "tracing_config" {
    for_each = each.value.xray_tracing_mode != null ? [each.value.xray_tracing_mode] : []
    content {
      mode = tracing_config.value
    }
  }

  dynamic "vpc_config" {
    for_each = each.value.vpc_config != null ? [each.value.vpc_config] : []
    content {
      subnet_ids                  = vpc_config.value.subnet_ids
      security_group_ids          = vpc_config.value.security_group_ids
      ipv6_allowed_for_dual_stack = vpc_config.value.ipv6_allowed
    }
  }

  code_signing_config_arn        = each.value.code_signing_config_arn != null ? each.value.code_signing_config_arn : null
  reserved_concurrent_executions = each.value.concurrency_level != null ? each.value.concurrency_level : null


  dynamic "dead_letter_config" {
    for_each = each.value.dlq_arn != null ? [each.value.dlq_arn] : []
    content {
      target_arn = dead_letter_config.value
    }
  }

  environment {
    variables = each.value.environment_variables
  }
  kms_key_arn = each.value.encryption_key_alias != null ? data.aws_kms_key.lambda_encryption_key[each.key].arn : null

  tags = local.merged_tags
}

resource "aws_cloudwatch_log_group" "lambda_logs" {
  #checkov:skip=CKV_AWS_338: 7 days retention is default, can be overridden by user input
  #checkov:skip=CKV_AWS_158: Default encryption is used as per "use all default values" instruction
  for_each          = var.lambda_defs
  name              = "/aws/lambda/${each.value.function_name}-${var.environment}"
  retention_in_days = var.lambda_log_retention
  tags              = local.merged_tags
}

resource "aws_iam_policy" "lambda_logging" {
  for_each = { for key, lambda_def in var.lambda_defs : key => lambda_def if lambda_def.execution_role_policy != null }
  name     = "${each.value.function_name}-${var.environment}-logging-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "${aws_cloudwatch_log_group.lambda_logs[each.key].arn}:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  for_each = { for key, lambda_def in var.lambda_defs : key => lambda_def if lambda_def.execution_role_policy != null }

  role       = aws_iam_role.lambda_exec_role[each.key].name
  policy_arn = aws_iam_policy.lambda_logging[each.key].arn
}

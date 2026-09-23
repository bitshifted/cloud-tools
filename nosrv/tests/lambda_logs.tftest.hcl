// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

mock_provider "aws" {
  override_data {
    target = data.aws_kms_key.lambda_encryption_key
    values = {
      arn    = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
      key_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}
mock_provider "archive" {}

override_data {
  target = data.aws_iam_policy_document.lambda_assume_role_policy
  values = {
    json = "{\"Version\": \"2012-10-17\", \"Statement\": [{\"Action\": \"sts:AssumeRole\", \"Effect\": \"Allow\", \"Principal\": {\"Service\": \"lambda.amazonaws.com\"}}]}"
  }
}

variables {
  environment = "test"
  revision    = "1.0.0"
}

run "verify_log_group_creation" {
  command = plan

  variables {
    lambda_defs = {
      managed_lambda = {
        function_name         = "managed-func"
        handler               = "index.handler"
        runtime               = "nodejs18.x"
        execution_role_policy = "{\"Version\": \"2012-10-17\", \"Statement\": [{\"Action\": \"s3:*\", \"Effect\": \"Allow\", \"Resource\": \"*\"}]}"
        zip_archive_config = {
          source_dir = "tests/src"
          output_dir = "/tmp"
        }
      }
      external_lambda = {
        function_name      = "external-func"
        handler            = "index.handler"
        runtime            = "nodejs18.x"
        execution_role_arn = "arn:aws:iam::123456789012:role/external-role"
        zip_archive_config = {
          source_dir = "tests/src"
          output_dir = "/tmp"
        }
      }
    }
    lambda_log_retention = 14
  }

  assert {
    condition     = aws_cloudwatch_log_group.lambda_logs["managed_lambda"].name == "/aws/lambda/managed-func-test"
    error_message = "Log group name for managed lambda is incorrect"
  }

  assert {
    condition     = aws_cloudwatch_log_group.lambda_logs["managed_lambda"].retention_in_days == 14
    error_message = "Log group retention for managed lambda is incorrect"
  }

  assert {
    condition     = aws_cloudwatch_log_group.lambda_logs["external_lambda"].name == "/aws/lambda/external-func-test"
    error_message = "Log group name for external lambda is incorrect"
  }

  assert {
    condition     = aws_cloudwatch_log_group.lambda_logs["external_lambda"].retention_in_days == 14
    error_message = "Log group retention for external lambda is incorrect"
  }
}

run "verify_logging_permissions" {
  command = plan

  variables {
    lambda_defs = {
      managed_lambda = {
        function_name         = "managed-func"
        handler               = "index.handler"
        runtime               = "nodejs18.x"
        execution_role_policy = "{\"Version\": \"2012-10-17\", \"Statement\": [{\"Action\": \"s3:*\", \"Effect\": \"Allow\", \"Resource\": \"*\"}]}"
        zip_archive_config = {
          source_dir = "tests/src"
          output_dir = "/tmp"
        }
      }
      external_lambda = {
        function_name      = "external-func"
        handler            = "index.handler"
        runtime            = "nodejs18.x"
        execution_role_arn = "arn:aws:iam::123456789012:role/external-role"
        zip_archive_config = {
          source_dir = "tests/src"
          output_dir = "/tmp"
        }
      }
    }
  }

  assert {
    condition     = length(aws_iam_policy.lambda_logging) == 1
    error_message = "Expected 1 logging policy for managed lambda"
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.lambda_logging) == 1
    error_message = "Expected 1 logging policy attachment for managed lambda"
  }

  assert {
    condition     = aws_iam_role_policy_attachment.lambda_logging["managed_lambda"].role == "managed-func-test-exec-role"
    error_message = "Logging policy attached to incorrect role"
  }
}

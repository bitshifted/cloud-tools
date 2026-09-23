// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

mock_provider "aws" {
  override_data {
    target = data.aws_iam_policy_document.lambda_assume_role_policy
    values = {
      json = "{}"
    }
  }
  override_data {
    target = data.aws_kms_key.lambda_encryption_key
    values = {
      arn    = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
      key_id = "00000000-0000-0000-0000-000000000000"
    }
  }
  override_resource {
    target = aws_iam_role.lambda_exec_role["test_lambda"]
    values = {
      arn = "arn:aws:iam::123456789012:role/test-lambda-test-exec-role"
    }
  }
  override_resource {
    target = aws_iam_policy.lambda_execution_policy["test_lambda"]
    values = {
      arn = "arn:aws:iam::123456789012:policy/test-lambda-test-exec-policy"
    }
  }
  override_resource {
    target = aws_iam_policy.lambda_logging["test_lambda"]
    values = {
      arn = "arn:aws:iam::123456789012:policy/test-lambda-test-logging-policy"
    }
  }
  override_resource {
    target = aws_cloudwatch_log_group.lambda_logs["test_lambda"]
    values = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/lambda/test-lambda-test"
    }
  }
}

variables {
  lambda_defs = {
    test_lambda = {
      function_name = "test-lambda"
      handler       = "index.handler"
      runtime       = "nodejs18.x"
      zip_archive_config = {
        source_dir = "tests/src"
        output_dir = "tests/dist"
      }
    }
  }
  environment = "test"
  revision    = "1.0.0"
}


run "existing_role_arn_is_used_when_specified" {
  command = plan

  variables {
    lambda_defs = {
      test_lambda = {
        function_name      = "test-lambda"
        handler            = "index.handler"
        runtime            = "nodejs18.x"
        execution_role_arn = "arn:aws:iam::123456789012:role/existing-role"
        zip_archive_config = {
          source_dir = "tests/src"
          output_dir = "tests/dist"
        }
        code_signing_config_arn = "arn:aws:lambda:us-east-1:123456789012:code-signing-config/abcd1234"
      }
    }
    environment = "test"
    revision    = "1.0.0"
  }


  assert {
    condition     = length(aws_iam_role.lambda_exec_role) == 0
    error_message = "New role should not be created when execution_role_arn is specified"
  }

  assert {
    condition     = aws_lambda_function.lambda_function["test_lambda"].role == "arn:aws:iam::123456789012:role/existing-role"
    error_message = "Lambda function should use the existing role ARN"
  }
}

run "new_role_is_created_when_execution_role_policy_specified" {
  command = apply

  variables {
    lambda_defs = {
      test_lambda = {
        function_name = "test-lambda"
        handler       = "index.handler"
        runtime       = "nodejs18.x"
        execution_role_policy = jsonencode({
          Version = "2012-10-17",
          Statement = [
            {
              Effect   = "Allow",
              Action   = ["s3:ListBucket"],
              Resource = ["arn:aws:s3:::example-bucket"]
            }
          ]
        })
        zip_archive_config = {
          source_dir = "tests/src"
          output_dir = "tests/dist"
        }
        code_signing_config_arn = "arn:aws:lambda:us-east-1:123456789012:code-signing-config/abcd1234"
      }
    }
    environment = "test"
    revision    = "1.0.0"
  }


  assert {
    condition     = length(aws_iam_role.lambda_exec_role) == 1
    error_message = "A new role should be created when execution_role_policy is specified and execution_role_arn is not provided"
  }

  assert {
    condition     = aws_lambda_function.lambda_function["test_lambda"].role == aws_iam_role.lambda_exec_role["test_lambda"].arn
    error_message = "Lambda function should use the ARN of the newly created role"
  }
}

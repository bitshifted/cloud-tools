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

run "create_lambda_with_minimum_config" {
  command = apply

  variables {
    lambda_defs = {
      test_lambda = {
        function_name      = "test-lambda"
        handler            = "index.handler"
        runtime            = "nodejs18.x"
        execution_role_arn = "arn:aws:iam::123456789012:role/existing-role"
        zip_archive_config = {
          source_dir = "tests/src"
          output_dir = "/tmp"
        }
        # code_signing_config_arn = "arn:aws:lambda:us-east-1:123456789012:code-signing-config/abcd1234"?
      }
    }
    environment = "test"
    revision    = "1.0.0"
  }

  assert {
    condition     = aws_lambda_function.lambda_function["test_lambda"].function_name == "test-lambda-test"
    error_message = "Function name is not set correctly"
  }

  assert {
    condition     = aws_lambda_function.lambda_function["test_lambda"].filename == "/tmp/test_lambda.zip"
    error_message = "Function code filename is not set correctly"
  }

  assert {
    condition     = aws_lambda_function.lambda_function["test_lambda"].role == "arn:aws:iam::123456789012:role/existing-role"
    error_message = "Function role ARN is not set correctly"
  }

  assert {
    condition     = aws_lambda_function.lambda_function["test_lambda"].tracing_config[0].mode == "Active"
    error_message = "X-Ray tracing mode is not set to Active by default"
  }

  assert {
    condition     = aws_lambda_function.lambda_function["test_lambda"].reserved_concurrent_executions == null
    error_message = "Concurrency level is not set to default value"
  }

}

run "environemnt_variables_are_set" {
  command = apply

  variables {
    lambda_defs = {
      env_lambda = {
        function_name      = "env-lambda"
        handler            = "index.handler"
        runtime            = "nodejs18.x"
        execution_role_arn = "arn:aws:iam::123456789012:role/existing-role"
        zip_archive_config = {
          source_dir = "tests/src"
          output_dir = "/tmp"
        }
        environment_variables = {
          VAR1 = "value1"
          VAR2 = "value2"
        }
      }
    }
    environment = "test"
    revision    = "1.0.0"
  }

  assert {
    condition     = aws_lambda_function.lambda_function["env_lambda"].environment[0].variables["VAR1"] == "value1" && aws_lambda_function.lambda_function["env_lambda"].environment[0].variables["VAR2"] == "value2"
    error_message = "Environment variables are not set correctly on the Lambda function"
  }
}
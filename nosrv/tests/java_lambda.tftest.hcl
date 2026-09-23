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

run "create_java_lambda_with_jar" {
  command = plan

  variables {
    lambda_defs = {
      java_lambda = {
        function_name      = "java-lambda"
        handler            = "com.example.Handler"
        runtime            = "java11"
        execution_role_arn = "arn:aws:iam::123456789012:role/existing-role"
        zip_archive_config = {
          source_file = "tests/test.jar"
          output_dir  = "/tmp"
        }
      }
    }
    environment = "test"
    revision    = "1.0.0"
  }

  assert {
    condition     = aws_lambda_function.lambda_function["java_lambda"].filename == "tests/test.jar"
    error_message = "Java function should use the JAR file directly"
  }
}

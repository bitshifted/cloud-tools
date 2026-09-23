// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

mock_provider "aws" {
}

run "java_lambda_missing_config_fails" {
  command = plan

  variables {
    lambda_defs = {
      java_lambda = {
        function_name      = "java-lambda"
        handler            = "com.example.Handler"
        runtime            = "java11"
        execution_role_arn = "arn:aws:iam::123456789012:role/existing-role"
        # missing zip_archive_config
      }
    }
    environment = "test"
    revision    = "1.0.0"
  }

  expect_failures = [
    var.lambda_defs
  ]
}

run "java_lambda_missing_source_file_fails" {
  command = plan

  variables {
    lambda_defs = {
      java_lambda = {
        function_name      = "java-lambda"
        handler            = "com.example.Handler"
        runtime            = "java11"
        execution_role_arn = "arn:aws:iam::123456789012:role/existing-role"
        zip_archive_config = {
          # missing source_file
          output_dir = "/tmp"
        }
      }
    }
    environment = "test"
    revision    = "1.0.0"
  }

  expect_failures = [
    var.lambda_defs
  ]
}

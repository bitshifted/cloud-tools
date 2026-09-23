// Copyright 2026 Bitshift ED (https://www.bitshifted.com)


mock_provider "aws" {

}

run "invalid_execution_role_when_non_specified" {
  command = plan

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
        code_signing_config_arn = "arn:aws:lambda:us-east-1:123456789012:code-signing-config/abcd1234"
      }
    }
    environment = "test"
    revision    = "1.0.0"
  }


  expect_failures = [
    var.lambda_defs["test_lambda"].execution_role_arn
  ]
}

run "invalid_execution_role_when_both_specified" {
  command = plan

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
        execution_role_arn      = "arn:aws:::iam/role/1234"
        execution_role_policy   = "{}"
        code_signing_config_arn = "arn:aws:lambda:us-east-1:123456789012:code-signing-config/abcd1234"
      }
    }
    environment = "test"
    revision    = "1.0.0"
  }


  expect_failures = [
    var.lambda_defs["test_lambda"].execution_role_arn
  ]
}


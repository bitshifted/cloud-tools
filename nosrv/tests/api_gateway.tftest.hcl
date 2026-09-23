// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

mock_provider "aws" {
  override_data {
    target = data.aws_kms_key.lambda_encryption_key["test_lambda"]
    values = {
      arn    = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
      key_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

variables {
  environment = "test"
  revision    = "1.0.0"
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
    }
  }
}

# Basic test to ensure variables are correctly handled
run "setup" {
  command = plan
}

run "create_api_gateway_success" {
  command = apply

  variables {
    enable_api_gateway = true
    api_name           = "test-api"
    openapi_spec_path  = "tests/test-spec.yaml"
  }

  override_resource {
    target = aws_apigatewayv2_api.this[0]
    values = {
      execution_arn = "arn:aws:execute-api:us-east-1:123456789012:api-id"
    }
  }

  override_resource {
    target = aws_cloudwatch_log_group.api_gateway[0]
    values = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/v2api/test-api-test"
    }
  }

  assert {
    condition     = aws_apigatewayv2_api.this[0].name == "test-api-test"
    error_message = "API Gateway name is not set correctly"
  }

  assert {
    condition     = can(regex("test_lambda", aws_apigatewayv2_api.this[0].body))
    error_message = "Token replacement in OpenAPI spec failed"
  }
}

run "api_gateway_disabled" {
  command = plan

  variables {
    enable_api_gateway = false
  }

  assert {
    condition     = length(aws_apigatewayv2_api.this) == 0
    error_message = "API Gateway should not be created when disabled"
  }
}

run "lambda_permissions_created" {
  command = apply

  variables {
    enable_api_gateway = true
    api_name           = "test-api"
    openapi_spec_path  = "tests/test-spec.yaml"
  }

  override_resource {
    target = aws_apigatewayv2_api.this[0]
    values = {
      execution_arn = "arn:aws:execute-api:us-east-1:123456789012:api-id"
    }
  }

  override_resource {
    target = aws_cloudwatch_log_group.api_gateway[0]
    values = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/v2api/test-api-test"
    }
  }

  assert {
    condition     = length(aws_lambda_permission.api_gateway) > 0
    error_message = "Lambda permissions for API Gateway were not created"
  }

  assert {
    condition     = aws_lambda_permission.api_gateway["test_lambda"].action == "lambda:InvokeFunction"
    error_message = "Lambda permission action is incorrect"
  }

  assert {
    condition     = aws_lambda_permission.api_gateway["test_lambda"].principal == "apigateway.amazonaws.com"
    error_message = "Lambda permission principal is incorrect"
  }
}

run "api_stage_name_matches_environment" {
  command = apply

  variables {
    enable_api_gateway = true
    api_name           = "test-api"
    openapi_spec_path  = "tests/test-spec.yaml"
    environment        = "prod"
    enable_api_logging = false
  }

  assert {
    condition     = aws_apigatewayv2_stage.this[0].name == "prod"
    error_message = "API Stage name does not match environment"
  }

  assert {
    condition     = aws_apigatewayv2_stage.this[0].auto_deploy == true
    error_message = "API Stage auto_deploy should be true"
  }
}

run "api_logging_configured" {
  command = apply

  variables {
    enable_api_gateway = true
    api_name           = "test-api"
    openapi_spec_path  = "tests/test-spec.yaml"
    enable_api_logging = true
    api_log_retention  = 14
  }

  override_resource {
    target = aws_apigatewayv2_api.this[0]
    values = {
      execution_arn = "arn:aws:execute-api:us-east-1:123456789012:api-id"
    }
  }

  override_resource {
    target = aws_cloudwatch_log_group.api_gateway[0]
    values = {
      arn = "arn:aws:logs:us-east-1:123456789012:log-group:/aws/v2api/test-api-test"
    }
  }

  assert {
    condition     = length(aws_cloudwatch_log_group.api_gateway) == 1
    error_message = "CloudWatch log group for API Gateway was not created"
  }

  assert {
    condition     = aws_cloudwatch_log_group.api_gateway[0].retention_in_days == 14
    error_message = "Log retention is not set correctly"
  }

  assert {
    condition     = can(aws_apigatewayv2_stage.this[0].access_log_settings[0].destination_arn)
    error_message = "Access logging not configured on API Stage"
  }
}

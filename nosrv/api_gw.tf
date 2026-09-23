# Copyright 2026 Bitshift ED (https://www.bitshifted.com)

locals {
  lambda_arns = {
    for k, v in aws_lambda_function.lambda_function : k => v.invoke_arn
  }

  # Replace tokens in OpenAPI spec using templatestring
  rendered_openapi_spec = var.enable_api_gateway && var.openapi_spec_path != null ? templatefile(var.openapi_spec_path, local.lambda_arns) : null
}

# API Gateway resource definitions for the nosrv module. This includes the API itself, stages, and permissions for Lambda invocation.
resource "aws_apigatewayv2_api" "this" {
  count = var.enable_api_gateway ? 1 : 0

  name          = "${var.api_name}-${var.environment}"
  protocol_type = "HTTP"
  body          = local.rendered_openapi_spec

  lifecycle {
    precondition {
      condition     = var.api_name != null
      error_message = "api_name must be provided when enable_api_gateway is true."
    }
    precondition {
      condition     = var.openapi_spec_path != null
      error_message = "openapi_spec must be provided when enable_api_gateway is true."
    }
  }

  tags = local.merged_tags
}

# Permissions to allow API Gateway to invoke the Lambdas defined in lambda_defs.
resource "aws_lambda_permission" "api_gateway" {
  for_each = {
    for k, v in var.lambda_defs : k => v
    if var.enable_api_gateway && var.openapi_spec_path != null
  }

  statement_id  = "AllowExecutionFromAPIGateway-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function[each.key].function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this[0].execution_arn}/*/*"
}

# API Gateway stage with optional access logging.
resource "aws_apigatewayv2_stage" "this" {
  count = var.enable_api_gateway ? 1 : 0

  api_id      = aws_apigatewayv2_api.this[0].id
  name        = var.environment
  auto_deploy = true

  dynamic "access_log_settings" {
    for_each = var.enable_api_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gateway[0].arn
      format          = "$context.identity.sourceIp $context.identity.caller $context.identity.user [$context.requestTime] \"$context.httpMethod $context.resourcePath $context.protocol\" $context.status $context.responseLength $context.requestId"
    }
  }

  tags = local.merged_tags
}

# CloudWatch Log Group for API Gateway access logs, created only if logging is enabled.
resource "aws_cloudwatch_log_group" "api_gateway" {
  count = var.enable_api_gateway && var.enable_api_logging ? 1 : 0

  name              = "/aws/v2api/${var.api_name}-${var.environment}"
  retention_in_days = var.api_log_retention

  tags = local.merged_tags
}

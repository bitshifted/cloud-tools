# Copyright 2026 Bitshift ED (https://www.bitshifted.com)


output "lambda_function_arn" {
  value = {
    for key, lambda_function in aws_lambda_function.lambda_function : key => lambda_function.arn
  }
  description = "Map of function name to function ARN"
}

output "sqs_arns" {
  value = {
    for key, sqs_queue in aws_sqs_queue.main : key => sqs_queue.arn
  }
  description = "Map of queue name to queue ARN"
}

output "sqs_urls" {
  value = {
    for key, sqs_queue in aws_sqs_queue.main : key => sqs_queue.url
  }
  description = "Map of queue name to queue URL"
}

output "api_endpoint" {
  value       = var.enable_api_gateway ? aws_apigatewayv2_stage.this[0].invoke_url : null
  description = "The URI of the API Gateway Stage."
}

output "api_id" {
  value       = var.enable_api_gateway ? aws_apigatewayv2_api.this[0].id : null
  description = "The ID of the API Gateway."
}

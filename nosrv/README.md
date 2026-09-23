# NoSrv

<!-- BEGIN_TF_DOCS -->
## NoSrv

Serverless application stack configuration.

## Contents
* [Requirements](#requirements)
* [Providers](#providers)
* [Resources](#resources)
* [Inputs](#inputs)
* [Outputs](#outputs)
* [Examples](#examples)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >= 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | 2.7.1 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.41.0 |

## Resources
| Name | Type |
|------|------|
| [aws_apigatewayv2_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
|**Description:** API Gateway resource definitions for the nosrv module. This includes the API itself, stages, and permissions for Lambda invocation. ||
| [aws_apigatewayv2_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
|**Description:** API Gateway stage with optional access logging. ||
| [aws_cloudwatch_log_group.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
|**Description:** CloudWatch Log Group for API Gateway access logs, created only if logging is enabled. ||
| [aws_cloudwatch_log_group.lambda_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
|**Description:**  ||
| [aws_iam_policy.lambda_execution_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
|**Description:**  ||
| [aws_iam_policy.lambda_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
|**Description:**  ||
| [aws_iam_role.lambda_exec_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
|**Description:**  ||
| [aws_iam_role_policy_attachment.lambda_exec_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
|**Description:**  ||
| [aws_iam_role_policy_attachment.lambda_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
|**Description:**  ||
| [aws_lambda_function.lambda_function](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
|**Description:**  ||
| [aws_lambda_permission.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
|**Description:** Permissions to allow API Gateway to invoke the Lambdas defined in lambda\_defs. ||
| [aws_sqs_queue.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
|**Description:** Main SQS queues defined in sqs\_defs. ||
| [aws_sqs_queue.shared_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
|**Description:** Shared Dead Letter Queue for all SQS queues in this module instance. ||
| [aws_sqs_queue_redrive_allow_policy.shared_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_redrive_allow_policy) | resource |
|**Description:** Redrive allow policy for the shared DLQ. ||

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_log_retention"></a> [api\_log\_retention](#input\_api\_log\_retention) | Retention in days for API access logs. | `number` | `7` | no |
| <a name="input_api_name"></a> [api\_name](#input\_api\_name) | Base name for the API Gateway. Required if `enable_api_gateway` is true. | `string` | `null` | no |
| <a name="input_dlq_name"></a> [dlq\_name](#input\_dlq\_name) | Name of the shared SQS DLQ. | `string` | `"sqs-shared-dlq"` | no |
| <a name="input_enable_api_gateway"></a> [enable\_api\_gateway](#input\_enable\_api\_gateway) | Whether to create the API Gateway resources. | `bool` | `false` | no |
| <a name="input_enable_api_logging"></a> [enable\_api\_logging](#input\_enable\_api\_logging) | Enable CloudWatch access logging for the API Stage. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for this Terraform stack (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_lambda_defs"></a> [lambda\_defs](#input\_lambda\_defs) | Map of Lambda function definitions. Defaults to empty map. | <pre>map(object({<br/>    function_name         = string<br/>    handler               = string<br/>    runtime               = string<br/>    execution_role_arn    = optional(string, null)<br/>    execution_role_policy = optional(string, null)<br/>    memory                = optional(number, 128)<br/>    timeout               = optional(number, 10)<br/>    xray_tracing_mode     = optional(string, "Active")<br/>    zip_archive_config = optional(object({<br/>      source_file = optional(string, null)<br/>      source_dir  = optional(string, null)<br/>      output_dir  = string<br/>    }), null)<br/>    code_signing_config_arn = optional(string, null)<br/>    concurrency_level       = optional(number, null)<br/>    dlq_arn                 = optional(string, null)<br/>    vpc_config = optional(object({<br/>      subnet_ids         = list(string)<br/>      security_group_ids = list(string)<br/>      ipv6_allowed       = optional(bool, false)<br/>    }), null)<br/>    environment_variables = optional(map(string), {})<br/>    encryption_key_alias  = optional(string, null)<br/>  }))</pre> | `{}` | no |
| <a name="input_lambda_log_retention"></a> [lambda\_log\_retention](#input\_lambda\_log\_retention) | Retention in days for Lambda CloudWatch Log Groups. Defaults to 7 days. | `number` | `7` | no |
| <a name="input_openapi_spec_path"></a> [openapi\_spec\_path](#input\_openapi\_spec\_path) | Path to the OpenAPI 3.x specification in YAML format. Use ${lambda\_key} for Lambda ARNs. | `string` | `null` | no |
| <a name="input_revision"></a> [revision](#input\_revision) | Version information for this stack. Should be updated with every change | `string` | n/a | yes |
| <a name="input_sqs_defs"></a> [sqs\_defs](#input\_sqs\_defs) | Map of SQS queue definitions. Suffixes with environment and associates with shared DLQ by default. | <pre>map(object({<br/>    name                       = string<br/>    is_fifo                    = optional(bool, false)<br/>    use_dlq                    = optional(bool, true)<br/>    visibility_timeout_seconds = optional(number, 30)<br/>    message_retention_seconds  = optional(number, 345600)<br/>    max_receive_count          = optional(number, 5)<br/>  }))</pre> | `{}` | no |
| <a name="input_sqs_kms_key_alias"></a> [sqs\_kms\_key\_alias](#input\_sqs\_kms\_key\_alias) | Alias of the KMS key to use for SQS encryption. Defaults to AWS managed key if not provided. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all created resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | The URI of the API Gateway Stage. |
| <a name="output_api_id"></a> [api\_id](#output\_api\_id) | The ID of the API Gateway. |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | Map of function name to function ARN |
| <a name="output_sqs_arns"></a> [sqs\_arns](#output\_sqs\_arns) | Map of queue name to queue ARN |
| <a name="output_sqs_urls"></a> [sqs\_urls](#output\_sqs\_urls) | Map of queue name to queue URL |

## Code examples
<!-- END_TF_DOCS -->


<!-- BEGIN_TF_DOCS -->
# ddb-express

DynamoDB table module with sensible default configs for production-ready workloads.

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.40.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.40.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Resources
| Name | Type |
|------|------|
| [aws_appautoscaling_policy.gsi_read_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
|**Description:**  ||
| [aws_appautoscaling_policy.gsi_write_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
|**Description:**  ||
| [aws_appautoscaling_policy.table_read_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
|**Description:**  ||
| [aws_appautoscaling_policy.table_write_autoscaling_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
|**Description:**  ||
| [aws_appautoscaling_target.gsi_read_autoscaling_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
|**Description:**  ||
| [aws_appautoscaling_target.gsi_write_autoscaling_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
|**Description:**  ||
| [aws_appautoscaling_target.table_read_autoscaling_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
|**Description:**  ||
| [aws_appautoscaling_target.table_write_autoscaling_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
|**Description:**  ||
| [aws_dynamodb_table.db_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
|**Description:** Dynamo DB table to create ||
| [aws_kms_alias.db_encryption_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
|**Description:** Alias for the created KMS key to make it easier to reference in the DynamoDB table resource. Only created if encryption\_key\_arn variable is not provided ||
| [aws_kms_key.db_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
|**Description:** Encryption key for the table. Only created if encryption\_key\_arn variable is not provided, and CMK usage is enabled ||
| [terraform_data.db_seeder](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
|**Description:**  ||

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attributes"></a> [attributes](#input\_attributes) | n/a | <pre>list(object({<br/>    attr_name = string<br/>    attr_type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_authorized_kms_principals"></a> [authorized\_kms\_principals](#input\_authorized\_kms\_principals) | List of IAM principal ARNs authorized to use the KMS key for cryptographic operations. | `list(string)` | `[]` | no |
| <a name="input_auto_scaling_config"></a> [auto\_scaling\_config](#input\_auto\_scaling\_config) | Table auto scaling configuration. Used only if capacity mode is `PROVISIONED` | <pre>object({<br/>    enabled = optional(bool, true)<br/>    read_config = optional(object({<br/>      min_capacity = optional(number, 25)<br/>      max_capacity = optional(number, 100)<br/>    }), {})<br/>    write_config = optional(object({<br/>      min_capacity = optional(number, 25)<br/>      max_capacity = optional(number, 100)<br/>    }), {})<br/>  })</pre> | `{}` | no |
| <a name="input_aws_cli_command"></a> [aws\_cli\_command](#input\_aws\_cli\_command) | Name of AWS CLI command (defaults to 'aws'). Usefull when you use local setup with tools like 'awslocal'm | `string` | `"aws"` | no |
| <a name="input_capacity_config"></a> [capacity\_config](#input\_capacity\_config) | Consolidated capacity and billing configuration for the DynamoDB table. | <pre>object({<br/>    billing_mode   = optional(string, "PAY_PER_REQUEST")<br/>    table_class    = optional(string, "STANDARD")<br/>    read_capacity  = optional(number, null)<br/>    write_capacity = optional(number, null)<br/>    on_demand_throughput = optional(object({<br/>      max_read_request_units  = optional(number, null)<br/>      max_write_request_units = optional(number, null)<br/>    }), null)<br/>    warm_throughput = optional(object({<br/>      read_units_per_second  = optional(number, null)<br/>      write_units_per_second = optional(number, null)<br/>    }), null)<br/>  })</pre> | `{}` | no |
| <a name="input_enable_delete_protection"></a> [enable\_delete\_protection](#input\_enable\_delete\_protection) | Enables deletion protection on table. Deafults to true. | `bool` | `true` | no |
| <a name="input_encryption_key_arn"></a> [encryption\_key\_arn](#input\_encryption\_key\_arn) | ARN of KMS key used to encrypt table | `string` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for this Terraform configuration (ie. dev, prod, staging) | `string` | n/a | yes |
| <a name="input_gsi_list"></a> [gsi\_list](#input\_gsi\_list) | Global secondary indexes configuration | <pre>list(object({<br/>    name            = string<br/>    hash_key        = string<br/>    projection_type = optional(string, "ALL")<br/>    range_key       = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_hash_key_attribute"></a> [hash\_key\_attribute](#input\_hash\_key\_attribute) | Name of the attribute used as table hash key | `string` | n/a | yes |
| <a name="input_lsi_list"></a> [lsi\_list](#input\_lsi\_list) | Local secondary indexes configuration | <pre>list(object({<br/>    name               = string<br/>    range_key          = string<br/>    projection_type    = optional(string, "ALL")<br/>    non_key_attributes = optional(list(string), [])<br/>  }))</pre> | `[]` | no |
| <a name="input_point_in_time_recovery_enabled"></a> [point\_in\_time\_recovery\_enabled](#input\_point\_in\_time\_recovery\_enabled) | Enables point in time recovery (deault 'true') | `bool` | `true` | no |
| <a name="input_range_key_attribute"></a> [range\_key\_attribute](#input\_range\_key\_attribute) | Name of the attribute used as table range key (optional) | `string` | `null` | no |
| <a name="input_recovery_period"></a> [recovery\_period](#input\_recovery\_period) | Number of days to retain recovery points (default 35) | `number` | `35` | no |
| <a name="input_revision"></a> [revision](#input\_revision) | Version information for this stack. Should be updated with every chang | `string` | n/a | yes |
| <a name="input_seed_data_file_path"></a> [seed\_data\_file\_path](#input\_seed\_data\_file\_path) | Path to the file containing seed data to initialize database. File should be in valid DynamoDB JSON format | `string` | `null` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | DynamoDB stream view type (KEYS\_ONLY, NEW\_IMAGE, OLD\_IMAGE, NEW\_AND\_OLD\_IMAGES) | `string` | `null` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Name of DynamoDB table | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources | `map(string)` | `{}` | no |
| <a name="input_ttl_attribute"></a> [ttl\_attribute](#input\_ttl\_attribute) | Name of the attribute used for Time to Live (TTL) settings. If set, enables TTL on the table. | `string` | `null` | no |
| <a name="input_use_cmk_kms_key"></a> [use\_cmk\_kms\_key](#input\_use\_cmk\_kms\_key) | Whether to use a customer-managed KMS key for encryption. If `true` (default):<br/>  * key specified in `encryption_key_arn` will be used<br/>  * if `encryption_key_arn` is not set, new key will be created. <br/>If varaible is  `false`, the default AWS-managed KMS key for DynamoDB will be used. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_table_arn"></a> [table\_arn](#output\_table\_arn) | ARN of created Dynamo DB table |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | Name of created Dynamo DB table |

# Examples

## Basic Table with LSI

```hcl
module "table" {
  source = "./ddb-express"

  table_name          = "orders"
  hash_key_attribute  = "OrderID"
  range_key_attribute = "OrderDate"

  attributes = [
    { attr_name = "OrderID", attr_type = "S" },
    { attr_name = "OrderDate", attr_type = "S" },
    { attr_name = "Status", attr_type = "S" }
  ]

  lsi_list = [
    {
      name            = "StatusIndex"
      range_key       = "Status"
      projection_type = "ALL"
    }
  ]
}
```
<!-- END_TF_DOCS -->
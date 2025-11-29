<!-- BEGIN_TF_DOCS -->
# codeartifact-repo Terraform module

This module is intended to configure AWS CodeArtifact domains and repositories.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.21.0 |

## Resources

| Name | Type |
|------|------|
| [aws_codeartifact_domain.repo_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_domain) | resource |
| [aws_codeartifact_domain_permissions_policy.domain_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_domain_permissions_policy) | resource |
| [aws_codeartifact_repository.repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_repository) | resource |
| [aws_codeartifact_repository_permissions_policy.repo_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_repository_permissions_policy) | resource |
| [aws_kms_key.domain_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_domain_encryption_key_policy_path"></a> [domain\_encryption\_key\_policy\_path](#input\_domain\_encryption\_key\_policy\_path) | Path to file containing IAM policy to be applied to created encryption key | `string` | `null` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name of the repository | `string` | n/a | yes |
| <a name="input_domain_owner"></a> [domain\_owner](#input\_domain\_owner) | Account number of the account that owns the repository. If not set, defaults to the account running Terraform | `string` | `null` | no |
| <a name="input_domain_permissions_policy_revision"></a> [domain\_permissions\_policy\_revision](#input\_domain\_permissions\_policy\_revision) | Current revision of the domain permission policy to set | `string` | `null` | no |
| <a name="input_domain_policy_document_path"></a> [domain\_policy\_document\_path](#input\_domain\_policy\_document\_path) | Path to IAM policy document applied to Codeartifact domain | `string` | `null` | no |
| <a name="input_encryption_key_arn"></a> [encryption\_key\_arn](#input\_encryption\_key\_arn) | ARN of KMS key used for repository encryption. If not specified, and use\_default\_ecnryption\_key is false, creates new KMS key | `string` | `null` | no |
| <a name="input_repo_region"></a> [repo\_region](#input\_repo\_region) | Region in which repository will be managed. If not specified, defaults to region configured for provider | `string` | `null` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of repositories within Codeartifact domain | <pre>list(object({<br/>    repository_name                 = string<br/>    description                     = optional(string, "")<br/>    region                          = optional(string, null)<br/>    domain_owner                    = optional(string, null)<br/>    upstream                        = optional(string, null)<br/>    external_connection             = optional(string, null)<br/>    policy_document_path            = optional(string, null)<br/>    default_read_access_principals  = optional(list(string), null)<br/>    default_write_access_principals = optional(list(string), null)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources | `map(string)` | `{}` | no |
| <a name="input_use_default_ecnryption_key"></a> [use\_default\_ecnryption\_key](#input\_use\_default\_ecnryption\_key) | Whether to use default  Codeartifact KMS key (defaults to true) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_created_repositories"></a> [created\_repositories](#output\_created\_repositories) | A list of names of the created repositories. |
| <a name="output_domain"></a> [domain](#output\_domain) | Name of the CodeArtifact domain |
| <a name="output_domain_owner"></a> [domain\_owner](#output\_domain\_owner) | Owner account of the CodeArtifact domain |

## Examples
<!-- END_TF_DOCS -->
<!-- BEGIN_TF_DOCS -->
# Easy ECR

This Terraform module provides production-ready ECR repository for storing container images.

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
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.25.0 |

## Resources
| Name | Type |
|------|------|
| [aws_ecr_account_setting.account_scan_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_account_setting) | resource |
|**Description:**  ||
| [aws_ecr_lifecycle_policy.repo_lifecycle_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
|**Description:**  ||
| [aws_ecr_pull_through_cache_rule.custom_pullthrough_cache_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
|**Description:**  ||
| [aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
|**Description:**  ||
| [aws_ecr_registry_policy.registry_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_policy) | resource |
|**Description:**  ||
| [aws_ecr_repository.ecr_private_repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
|**Description:**  ||
| [aws_ecr_repository_policy.repo_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
|**Description:**  ||
| [aws_ecrpublic_repository.ecr_public_repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecrpublic_repository) | resource |
|**Description:**  ||
| [aws_ecrpublic_repository_policy.public_repo_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecrpublic_repository_policy) | resource |
|**Description:**  ||
| [aws_kms_key.domain_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
|**Description:**  ||

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_public_pullthrough_cache_rule"></a> [aws\_public\_pullthrough\_cache\_rule](#input\_aws\_public\_pullthrough\_cache\_rule) | Pullthrough cache rule for AWS public registry. Override default values to customize | <pre>object({<br/>    enabled                    = optional(bool, false)<br/>    ecr_repository_prefix      = optional(string, "ROOT")<br/>    upstream_repository_prefix = optional(string, "ROOT")<br/>  })</pre> | `{}` | no |
| <a name="input_default_account_scan_config"></a> [default\_account\_scan\_config](#input\_default\_account\_scan\_config) | Default ECR basic scan type configuration. | <pre>object({<br/>    name  = string<br/>    value = string<br/>  })</pre> | <pre>{<br/>  "name": "BASIC_SCAN_TYPE_VERSION",<br/>  "value": "AWS_NATIVE"<br/>}</pre> | no |
| <a name="input_docker_hub_pullthrough_cache_rule"></a> [docker\_hub\_pullthrough\_cache\_rule](#input\_docker\_hub\_pullthrough\_cache\_rule) | Pullthrough cache rule for Docker Hub  registry. Override default values to customize | <pre>object({<br/>    enabled                    = optional(bool, false)<br/>    ecr_repository_prefix      = optional(string, "ROOT")<br/>    upstream_repository_prefix = optional(string, "ROOT")<br/>    credential_arn             = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_domain_encryption_key_policy_path"></a> [domain\_encryption\_key\_policy\_path](#input\_domain\_encryption\_key\_policy\_path) | Local path to policy file to be applied to created KMS key. If not specified, no custom policy is applied. | `string` | `null` | no |
| <a name="input_ecr_region"></a> [ecr\_region](#input\_ecr\_region) | Region in which repositories will be managed. If not specified, defaults to region configured for provider | `string` | `null` | no |
| <a name="input_encryption_key_arn"></a> [encryption\_key\_arn](#input\_encryption\_key\_arn) | ARN of KMS key used for repository encryption. If not specified, and use\_default\_ecnryption\_key is false, creates new KMS key | `string` | `null` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | If 'true', deletes repository even if it has contents | `bool` | `false` | no |
| <a name="input_github_cr_pullthrough_cache_rule"></a> [github\_cr\_pullthrough\_cache\_rule](#input\_github\_cr\_pullthrough\_cache\_rule) | Pullthrough cache rule for Github Container  registry. Override default values to customize | <pre>object({<br/>    enabled                    = optional(bool, false)<br/>    ecr_repository_prefix      = optional(string, "ROOT")<br/>    upstream_repository_prefix = optional(string, "ROOT")<br/>    credential_arn             = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_gitlab_cr_pullthrough_cache_rule"></a> [gitlab\_cr\_pullthrough\_cache\_rule](#input\_gitlab\_cr\_pullthrough\_cache\_rule) | Pullthrough cache rule for Gitlab Container  registry. Override default values to customize | <pre>object({<br/>    enabled                    = optional(bool, false)<br/>    ecr_repository_prefix      = optional(string, "ROOT")<br/>    upstream_repository_prefix = optional(string, "ROOT")<br/>    credential_arn             = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_image_lifecycle_policy_path"></a> [image\_lifecycle\_policy\_path](#input\_image\_lifecycle\_policy\_path) | Path to JSON  file providing lifecycle policy for the repository | `string` | `null` | no |
| <a name="input_image_tag_mutable"></a> [image\_tag\_mutable](#input\_image\_tag\_mutable) | Whether image tags are mutable. Only applicable for private repositories. | `bool` | `true` | no |
| <a name="input_k8s_pullthrough_cache_rule"></a> [k8s\_pullthrough\_cache\_rule](#input\_k8s\_pullthrough\_cache\_rule) | Pullthrough cache rule for Kubernetes public registry. Override default values to customize | <pre>object({<br/>    enabled                    = optional(bool, false)<br/>    ecr_repository_prefix      = optional(string, "ROOT")<br/>    upstream_repository_prefix = optional(string, "ROOT")<br/>  })</pre> | `{}` | no |
| <a name="input_mutability_exclusion_filters"></a> [mutability\_exclusion\_filters](#input\_mutability\_exclusion\_filters) | List of tag prefixes to exclude from image tag mutability. Setting this will result in IMMUTABLE\_WITH\_EXLUSIONSo MUTABLE\_WITH\_EXCLUSION behavior. Only applicable for private repositories. | `list(string)` | `[]` | no |
| <a name="input_public_catalog_data"></a> [public\_catalog\_data](#input\_public\_catalog\_data) | Catalog data for public repositories (optional) | <pre>object({<br/>    about             = optional(string, ""),<br/>    description       = optional(string, ""),<br/>    architectures     = optional(list(string), []),<br/>    operating_systems = optional(list(string), []),<br/>    usage             = optional(string, ""),<br/>    logo_image_path   = optional(string, null)<br/>  })</pre> | `{}` | no |
| <a name="input_public_repo_policy_path"></a> [public\_repo\_policy\_path](#input\_public\_repo\_policy\_path) | Path to JSON policy file (optional). If specified, policy will be applied to public repository. | `string` | `null` | no |
| <a name="input_pullthrough_cache_rules"></a> [pullthrough\_cache\_rules](#input\_pullthrough\_cache\_rules) | List of custom pullthrough cache rules to apply to repository | <pre>list(object({<br/>    ecr_repository_prefix      = optional(string, "ROOT")<br/>    upstream_repository_prefix = optional(string, "ROOT")<br/>    credential_arn             = optional(string, null)<br/>    custom_role_arn            = optional(string, null)<br/>    upstream_registry_url      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_quay_pullthrough_cache_rule"></a> [quay\_pullthrough\_cache\_rule](#input\_quay\_pullthrough\_cache\_rule) | Pullthrough cache rule for Quay public registry. Override default values to customize | <pre>object({<br/>    enabled                    = optional(bool, false)<br/>    ecr_repository_prefix      = optional(string, "ROOT")<br/>    upstream_repository_prefix = optional(string, "ROOT")<br/>  })</pre> | `{}` | no |
| <a name="input_registry_policy_path"></a> [registry\_policy\_path](#input\_registry\_policy\_path) | Path to JSON policy file (optional). If specified, policy will be applied to registry | `string` | `null` | no |
| <a name="input_repo_policy_path"></a> [repo\_policy\_path](#input\_repo\_policy\_path) | Path to JSON policy file (optional). If specified, policy will be applied to repository | `string` | `null` | no |
| <a name="input_repository_name"></a> [repository\_name](#input\_repository\_name) | Name of the repository | `string` | n/a | yes |
| <a name="input_scan_images_on_push"></a> [scan\_images\_on\_push](#input\_scan\_images\_on\_push) | Whether images are scanned after being pushed to the repository (true) or not scanned (false). Default is true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources | `map(string)` | `{}` | no |
| <a name="input_use_default_ecnryption_key"></a> [use\_default\_ecnryption\_key](#input\_use\_default\_ecnryption\_key) | Whether to use default  ECR encryption key (defaults to true) | `bool` | `true` | no |
| <a name="input_use_default_image_lifecycle_policy"></a> [use\_default\_image\_lifecycle\_policy](#input\_use\_default\_image\_lifecycle\_policy) | Whether to use default image lifecycle or not. Defaults to true. | `bool` | `true` | no |
| <a name="input_visibility"></a> [visibility](#input\_visibility) | Visibility of the repository. Allowed values are 'PRIVATE' (default) and 'PUBLIC'. | `string` | `"PRIVATE"` | no |

## Outputs

No outputs.

## Examples

Examples configuration for using the module:

```hcl

module "easy_ecr" {
    source = ""https://github.com/bitshifted/cloud-tools//easy-ecr?ref=easy-ecr-<current version>"
}
```
<!-- END_TF_DOCS -->
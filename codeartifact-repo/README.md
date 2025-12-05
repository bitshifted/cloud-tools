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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.21.0 |

## Resources
| Name | Type |
|------|------|
| [aws_codeartifact_domain.repo_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_domain) | resource |
|**Description:** CodeArtifact domain acting as a container for repositories ||
| [aws_codeartifact_domain_permissions_policy.domain_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_domain_permissions_policy) | resource |
|**Description:** Optional  permissions policy applied to the created domain. Only created if a policy document path is provided. ||
| [aws_codeartifact_repository.repository](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_repository) | resource |
|**Description:** CodeArtifact repositories within the domain. Multiple repositories can be created by providing a list of repository configurations, ||
| [aws_codeartifact_repository_permissions_policy.repo_permissions_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_repository_permissions_policy) | resource |
|**Description:** Optional permissions policy applied to each repository. Only created if a policy document path is provided in the repository configuration. ||
| [aws_iam_role.admin_access_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
|**Description:** IAM role for admin access to domain and repositories. This should be assumed by the provided admin principals. Not created if no admin principals are provided. ||
| [aws_iam_role.publisher_access_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
|**Description:** IAM role for publisher access to domain and repositories. This should be assumed by the provided publisher principals. Not created if no publisher principals are provided. Publishers are allowed to publish packages in addition to read-only access. ||
| [aws_iam_role.read_access_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
|**Description:** IAM role for read-only access to domain and repositories. This should be assumed by the provided reader principals. Not created if no reader principals are provided. ||
| [aws_iam_role_policy.admin_access_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
|**Description:** IAM policy attaching admin permissions to the admin access role. Not created if no admin principals are provided. ||
| [aws_iam_role_policy.publisher_access_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
|**Description:** IAM policy attaching publisher permissions to the publisher access role. Not created if no publisher principals are provided. ||
| [aws_iam_role_policy.read_only_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
|**Description:** IAM policy attaching read-only permissions to the read access role. Not created if no reader principals are provided. ||
| [aws_kms_key.domain_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
|**Description:** Optional KMS key for domain encryption. Created only if no encryption key ARN is provided and default encryption key usage is disabled. ||

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_principals"></a> [admin\_principals](#input\_admin\_principals) | List of AWS principal ARNs that have admin access to domain and repositories | `list(string)` | `[]` | no |
| <a name="input_domain_encryption_key_policy_path"></a> [domain\_encryption\_key\_policy\_path](#input\_domain\_encryption\_key\_policy\_path) | Path to file containing IAM policy to be applied to created encryption key | `string` | `null` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain name of the repository | `string` | n/a | yes |
| <a name="input_domain_owner"></a> [domain\_owner](#input\_domain\_owner) | Account number of the account that owns the repository. If not set, defaults to the account running Terraform | `string` | `null` | no |
| <a name="input_domain_permissions_policy_revision"></a> [domain\_permissions\_policy\_revision](#input\_domain\_permissions\_policy\_revision) | Current revision of the domain permission policy to set | `string` | `null` | no |
| <a name="input_domain_policy_document_path"></a> [domain\_policy\_document\_path](#input\_domain\_policy\_document\_path) | Path to IAM policy document applied to Codeartifact domain | `string` | `null` | no |
| <a name="input_encryption_key_arn"></a> [encryption\_key\_arn](#input\_encryption\_key\_arn) | ARN of KMS key used for repository encryption. If not specified, and use\_default\_ecnryption\_key is false, creates new KMS key | `string` | `null` | no |
| <a name="input_publisher_principals"></a> [publisher\_principals](#input\_publisher\_principals) | List of AWS principal ARNS thet should have permissions to publish packages | `list(string)` | `[]` | no |
| <a name="input_reader_principals"></a> [reader\_principals](#input\_reader\_principals) | List of AWS principals ARNs that should have read access to domain and repositories | `list(string)` | `[]` | no |
| <a name="input_repo_region"></a> [repo\_region](#input\_repo\_region) | Region in which repositories will be managed. If not specified, defaults to region configured for provider | `string` | `null` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of repositories within Codeartifact domain | <pre>list(object({<br/>    repository_name      = string<br/>    description          = optional(string, "")<br/>    region               = optional(string, null)<br/>    domain_owner         = optional(string, null)<br/>    upstream             = optional(string, null)<br/>    external_connection  = optional(string, null)<br/>    policy_document_path = optional(string, null)<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to resources | `map(string)` | `{}` | no |
| <a name="input_use_default_ecnryption_key"></a> [use\_default\_ecnryption\_key](#input\_use\_default\_ecnryption\_key) | Whether to use default  Codeartifact KMS key (defaults to true) | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain"></a> [domain](#output\_domain) | Name of the CodeArtifact domain |
| <a name="output_domain_owner"></a> [domain\_owner](#output\_domain\_owner) | Owner account of the CodeArtifact domain |
| <a name="output_repo_urls"></a> [repo\_urls](#output\_repo\_urls) | A map of repository names to their repository endpoints. |

## Examples

Example configuration and usage of this module:

```hcl
module "my_repo" {
    # use repo URL as module source
    source = "https://github.com/bitshifted/cloud-tools//codeartifact-repo?ref=codeart-fact-repo-<current version>"

    # domain name to be used for domain
    domain_name = "my-domain"

    # don't use AWS default encryption key.
    use_default_ecnryption_key = false
    # use this KMS key for encryption. If not specified, new KMS key will be created
    encryption_key_arn = "arn:aws::/keys/1233"

    # IAM principals specified here will have read access to repositories, ie. able to pull paclages
    reader_principals = [
    "arn:aws:iam::11111111:user/reader",
  ]
  # IAM principals specified here will have write access to repositories, ie. able to publish packages
  publisher_principals = [
    "arn:aws:iam::22222222:user/publisher",
  ]

  repositories = [
    { 
        # repository name
        repository_name = "test-repo-2",
        # external connection to eg. upstream repository (optional)
        external_connection = "public:npmjs"
        # path to policy file that will be applied to repository
        policy_document_path = "./repo-policy.json"
     }
  ]
}
    
}
```
<!-- END_TF_DOCS -->
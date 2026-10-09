<!-- BEGIN_TF_DOCS -->
## Webfront

Deploys web application frontends (React, Angular, Vue etc.) on S3 and CloudFront. Provisions a secure S3 bucket with encryption, versioning, and access controls, plus an optional CloudFront distribution with Origin Access Identity for global delivery of static assets.

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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.68.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.index_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_abort_incomplete_multipart_upload_days"></a> [abort\_incomplete\_multipart\_upload\_days](#input\_abort\_incomplete\_multipart\_upload\_days) | Number of days after which to abort incomplete multipart uploads. Must be a positive integer. | `number` | `7` | no |
| <a name="input_access_logging_bucket_name"></a> [access\_logging\_bucket\_name](#input\_access\_logging\_bucket\_name) | Name of target bucket for access logs. Required when enable\_access\_logging is true. | `string` | `null` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket to host web application files | `string` | n/a | yes |
| <a name="input_comment"></a> [comment](#input\_comment) | Comment for the CloudFront distribution. | `string` | `""` | no |
| <a name="input_custom_domain_names"></a> [custom\_domain\_names](#input\_custom\_domain\_names) | CNAMEs (alternate domain names) for the CloudFront distribution. Requires ssl\_certificate\_arn. | `list(string)` | `[]` | no |
| <a name="input_cors_allowed_headers"></a> [cors\_allowed\_headers](#input\_cors\_allowed\_headers) | Allowed headers for CORS requests. | `list(string)` | <pre>[<br/>  "*"<br/>]</pre> | no |
| <a name="input_cors_allowed_methods"></a> [cors\_allowed\_methods](#input\_cors\_allowed\_methods) | Allowed HTTP methods for CORS requests. | `list(string)` | <pre>[<br/>  "GET",<br/>  "HEAD",<br/>  "PUT",<br/>  "POST",<br/>  "DELETE"<br/>]</pre> | no |
| <a name="input_cors_allowed_origins"></a> [cors\_allowed\_origins](#input\_cors\_allowed\_origins) | Allowed origins for CORS requests. | `list(string)` | `[]` | no |
| <a name="input_cors_expose_headers"></a> [cors\_expose\_headers](#input\_cors\_expose\_headers) | Headers exposed to browser for CORS responses. | `list(string)` | `[]` | no |
| <a name="input_cors_max_age"></a> [cors\_max\_age](#input\_cors\_max\_age) | Duration in seconds that browser caches CORS preflight response results. | `number` | `3600` | no |
| <a name="input_enable_access_logging"></a> [enable\_access\_logging](#input\_access\_logging) | Enable access logging for S3 bucket. Requires access\_logging\_bucket\_name to be set. | `bool` | `false` | no |
| <a name="input_enable_cloudfront"></a> [enable\_cloudfront](#input\_enable\_cloudfront) | Enable CloudFront distribution creation. Set to true when using CloudFront to serve content. | `bool` | `false` | no |
| <a name="input_enable_cors"></a> [enable\_cors](#input\_enable\_cors) | Whether to enable CORS configuration on the bucket. Enable when accessing from different origins. | `bool` | `false` | no |
| <a name="input_enable_host_error_pages"></a> [enable\_host\_error\_pages](#input\_host\_error\_pages) | Whether to deploy error pages (index.html and error.html). Required for CloudFront custom error handling. | `bool` | `true` | no |
| <a name="input_enable_versioning"></a> [enable\_versioning](#input\_enable\_versioning) | Enable versioning on S3 bucket to protect against accidental deletions and modifications | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment for this Terraform stack (e.g., dev, staging, prod) | `string` | n/a | yes |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | If true, allows destroying the bucket even if it contains objects (useful for development environments) | `bool` | `false` | no |
| <a name="input_forward_query_strings"></a> [forward\_query\_strings](#input\_forward\_query\_strings) | Whether to forward query strings to S3 origin in default cache behavior. | `bool` | `false` | no |
| <a name="input_html_pages"></a> [html\_pages](#input\_html\_pages) | List of HTML pages to upload. Each entry specifies key (filename), source\_file path, and optional metadata. | <pre>list(object({<br/>    key           = string<br/>    source_file   = string<br/>    content_type  = optional(string, "text/html; charset=utf-8")<br/>    cache_control = optional(string, "no-cache, no-store, must-revalidate")<br/>  }))</pre> | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key for S3 server-side encryption. If not provided, uses AWS managed key. | `string` | `null` | no |
| <a name="input_min_tls_version"></a> [min\_tls\_version](#input\_min\_tls\_version) | Minimum TLS version for viewer HTTPS connections. | `string` | `"TLSv1.2_2021"` | no |
| <a name="input_noncurrent_version_expiration_days"></a> [noncurrent\_version\_expiration\_days](#input\_version\_expiration\_days) | Number of days after which expired noncurrent versions are deleted. Must be positive integer. | `number` | `90` | no |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | CloudFront price class. Options: PriceClass\_100 (US only), PriceClass\_200 (US+Europe), PriceClass\_All (Global). | `string` | `"PriceClass_200"` | no |
| <a name="input_revision"></a> [revision](#input\_revision) | Version information for this stack. Should be updated with every change | `string` | n/a | yes |
| <a name="input_response_headers_policy_id"></a> [response\_headers\_policy\_id](#input\_response\_headers\_policy\_id) | Response headers policy ID to attach to the CloudFront distribution (e.g., security-headers-cors or AWS managed policy IDs). Defaults to AWS managed security-headers-cors policy. | `string` | `"67f77653-9e47-4d66-a105-70da5fcff96e"` | no |
| <a name="input_s3_object_lambda_policies"></a> [s3\_object\_lambda\_policies](#input\_object\_lambda\_policies) | Optional JSON policy document for S3 Object Lambda integration. | `string` | `null` | no |
| <a name="input_ssl_certificate_arn"></a> [ssl\_certificate\_arn](#input\_ssl\_certificate\_arn) | ACM certificate ARN in us-east-1 for custom domain names. Required when custom\_domain\_names is set. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to be applied to all resources created by this module | `map(string)` | `{}` | no |
| <a name="input_web_acl_id"></a> [web\_acl\_id](#input\_web\_acl\_id) | WAF Web ACL ARN to associate with the CloudFront distribution. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | The ARN of the S3 bucket. |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_domain\_name) | The bucket domain name in format: bucket-name.s3.amazonaws.com |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | The name of the S3 bucket. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | The name of the S3 bucket. |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_regional\_domain\_name) | The bucket region-specific domain name: bucket-name.s3.region-code.amazonaws.com |
| <a name="output_bucket_website_endpoint"></a> [bucket\_website\_endpoint](#output\_website\_endpoint) | The website endpoint, if the bucket is configured with a website. Null if not. |
| <a name="output_distribution_domain_name"></a> [distribution\_domain\_name](#output\_distribution\_domain\_name) | The domain name of the CloudFront distribution. |
| <a name="output_distribution_id"></a> [distribution\_id](#output\_distribution\_id) | The ID of the CloudFront distribution. |
| <a name="output_origin_access_identity_iam_arn"></a> [origin\_access\_identity\_iam\_arn](#output\_access\_identity\_iam\_arn) | The IAM ARN of the Origin Access Identity. |
| <a name="output_origin_access_identity_id"></a> [origin\_access\_identity\_id](#output\_access\_identity\_id) | The CloudFront Origin Access Identity ID. |

## Example - Secure S3 Bucket with CloudFront and Custom Domain

```hcl
module "webfront" {
  source = "../webfront"

  environment = "prod"
  revision    = "1.0.0"

  # S3 Configuration
  bucket_name             = "myapp-prod-static-assets"
  enable_host_error_pages = true

  html_pages = [
    {
      key         = "index.html"
      source_file = "./dist/index.html"
    },
    {
      key         = "error.html"
      source_file = "./dist/error.html"
    }
  ]

  # CloudFront Configuration
  enable_cloudfront     = true
  comment               = "MyApp Production - Static Assets"
  price_class           = "PriceClass_200"
  min_tls_version       = "TLSv1.2_2021"

  custom_domain_names   = ["static.example.com"]
  ssl_certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/xxxxx"

  tags = {
    Team       = "frontend"
    CostCenter = "12345"
  }
}
```
<!-- END_TF_DOCS -->

# Terraform Bootstrap AWS - Cloudformation template

This Cloudformation template is intended to bootstrap AWS S3 backend for use with Terraform pipelines. It creates S3 buckets and IAM roles needed to store Terraform state in S3. Template uses AWS-recommended best practices for security and data integrity.

## Motivation

Initial setup for Terraform S3 backend presents kind of *chicken and egg* problem: you can't run Terrafrom plan without backend, and you can't setup the backend using Terraform. There are some approaches that use different backends (eg. local) to bootstrap S3 backend, but they all have some shortcomings.

Approach outlined here uses AWS-native Cloudformation template to initialize all resources needed to bootstrap S3 backend. It is automated, can be run from CI/CD pipeline and, if needed, all resources can be deleted by deleting the stack.

The only drawback is that you have additional tool to use beside Terraform, but for one-time use, this can be considered good tradeoff.

## Resources

This template follows AWS and Terraform recommended best practices for backend security and compliance. It create the following resources:

* storage bucket - this bucket holds the actual Terraform state files. 
* access log bucket - contains access logs for state storage bucket. New bucket is created by default, but existing bucket can also be used, or access logging can be disabled completely.
* execution role - this role is assumed by Terraform during plan execution. Principal running the plan should have the permission to assume this role
* KMS key for bucket encryption (optional) - if configured, this key is used to encrypt contents in both storage and logs bucket. If not, AWS managed S3 encryption key is used

Each bucket it configured in the following way:

* no public access
* versioning enabled (for storage bucket only, not for access logs)
* encryption enabled 

## Parameters

Template can be customized by the following parameters:

* `BackendName` (required) - name of the backend. Will be used for bucket names
* `AssumeRolePrincipals` (required) - list of principals who are allowed to assume Terraform execution role
* `UseDefaultS3EncryptionKey` (optional) - if `true` (default) use default AWS managed S3 encryption key. Otherwise, use customer managed KMS key
* `BucketEncryptionKey` (optional) - ARN of the customer managed KMS key used for bucket encryption. If specified, and `UseDefaultS3EncryptionKey` is `false`, this key will be used for encryption. If not specified, and `UseDefaultS3EncryptionKey` is `false`, new KMS key will be created
* `EnableS3AccessLogging` (optional) - if `true` (default), S3 bucket for access logging will be use and access logging enabled. Otherwise, access logging will not be enabled.
* `CustomAccessLogBucket` (optional) - name of the custom S3 bucket to use for access logging. If not specified (default), and `EnableS3AccessLogging` is `true`, new bucket for access logs will be created
* `Environment` (requried) - value for the `Environment` tag applied to resources
* `Version` (requried) - value for the `Version` tag applied to resources

File `params.json.template` is the template JSON parameters file that can be customized and used to deploy a template.

## Deploying template

To deploy template, use the follwoing command

```
aws cloudformation deploy \ 
  --stack-name terraform-backend \
  --template-file ./tf-bootstrap.yml 
  --parameter-overrides file://params.json 
  --capabilities CAPABILITY_NAMED_IAM

```

## Terraform backend configuration

Use the following backend configuration in Terraform:

```hcl
terraform {
  backend "s3" {
     bucket = "bucket-name"
     region = "us-east-1"
     key = "path/to/my/terraform.tfstate"
     use_lockfile = true

     assume_role = {
       role_arn = "arn:aws:iam::123456789012:role/created-role"
     }
  }
}
```

This configuration assumes that principal running Terraform plan has permission to assume created role, as defined in the parameters for the stack.

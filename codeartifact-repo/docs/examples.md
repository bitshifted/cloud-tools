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

# Access module outputs

output "repo_urls" {
  value = module.codeartifact-repo.repo_urls
  description = "Map of repository URLs for access"
}

output "repo_domain" {
  value = module.codeartifact-repo.domain
}

output "repo_owner" {
  value = module.codeartifact-repo.domain_owner
}    

```
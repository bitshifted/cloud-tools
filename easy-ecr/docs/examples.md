## Examples

Examples configuration for using the module:

```hcl

module "easy_ecr" {
    source = ""https://github.com/bitshifted/cloud-tools//easy-ecr?ref=easy-ecr-<current version>"

    # name of repository to create
    repository_name = "test-private-repo"
    # whether image tags are MUTABLE (true) or IMMUTBLE (false)
    image_tag_mutable = false
    # exclusion filter to apply to image tags
    mutability_exclusion_filters = ["dev*"]

    # custom registry policy
    registry_policy_path = "./registry-policy.json"

    # custom repository -policy
    repo_policy_path = "./repo-policy.json"

    # pullthrough cache settings
   # enable pull through cache for AWS ECR public registry
   aws_public_pullthrough_cache_rule = {
    enabled = true
  }

  # principal ARNs listed here will have permissions to assume the role which allows pulling images from repository
  pull_only_principals = ["arn:aws:iam::12345667:user/user1"]

  # principal ARNs listed here will have permissions to assume the role which allows publishing images
  push_principals = ["arn:aws:iam::12345667:user/user1

  # tags applied to all created resources
  tags = {
    "Environment" = "Test"
    "Project" = "EasyEcrModule"
  }
}
```
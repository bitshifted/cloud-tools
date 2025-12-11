# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  
}

run "no_rules_should_be_created_by_default" {
    command = plan

    variables {
      repository_name = "test-repo"
    }

    assert {
      condition = length(aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule) == 0
      error_message = "Pullthrough cache rule was created, but should not be"
    }
}

run "rule_override_creates_aws_public_rule" {
    command = plan

    variables {
      repository_name = "test-repo"
      aws_public_pullthrough_cache_rule = {
        enabled = true
        upstream_repository_prefix = "my-prefix"
      }
    }

     assert {
      condition = length(aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule) == 1
      error_message = "Pullthrough cache rule was not created, but should  be"
    }

    assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["aws_public"].ecr_repository_prefix == "ROOT"
      error_message = "Invalid ECR repository prefix"
    }

     assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["aws_public"].upstream_repository_prefix == "my-prefix"
      error_message = "Invalid upstream repository prefix"
    }
}

run "rule_override_creates_k8s_public_rule" {
    command = plan

    variables {
      repository_name = "test-repo"
      k8s_pullthrough_cache_rule = {
        enabled = true
        upstream_repository_prefix = "my-prefix"
      }
    }

     assert {
      condition = length(aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule) == 1
      error_message = "Pullthrough cache rule was not created, but should  be"
    }

    assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["k8s_public"].ecr_repository_prefix == "ROOT"
      error_message = "Invalid ECR repository prefix"
    }

     assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["k8s_public"].upstream_repository_prefix == "my-prefix"
      error_message = "Invalid upstream repository prefix"
    }
}

run "rule_override_creates_quay_rule" {
    command = plan

    variables {
      repository_name = "test-repo"
      quay_pullthrough_cache_rule = {
        enabled = true
        upstream_repository_prefix = "my-prefix"
      }
    }

     assert {
      condition = length(aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule) == 1
      error_message = "Pullthrough cache rule was not created, but should  be"
    }

    assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["quay"].ecr_repository_prefix == "ROOT"
      error_message = "Invalid ECR repository prefix"
    }

     assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["quay"].upstream_repository_prefix == "my-prefix"
      error_message = "Invalid upstream repository prefix"
    }
}

run "rule_override_creates_docker_hub_rule" {
   command = plan

    variables {
      repository_name = "test-repo"
      docker_hub_pullthrough_cache_rule = {
        enabled = true
        upstream_repository_prefix = "my-prefix"
        credential_arn = "arn:aws:iam::123456789012:role/my-role"
      }
    }

     assert {
      condition = length(aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule) == 1
      error_message = "Pullthrough cache rule was not created, but should  be"
    }

    assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["docker_hub"].ecr_repository_prefix == "ROOT"
      error_message = "Invalid ECR repository prefix"
    }

    assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["docker_hub"].upstream_repository_prefix == "my-prefix"
      error_message = "Invalid upstream repository prefix"
    }

     assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["docker_hub"].credential_arn == "arn:aws:iam::123456789012:role/my-role"
      error_message = "Invalid credential ARN"
    }
}

run "rule_override_creates_github_cr_rule" {
   command = plan

    variables {
      repository_name = "test-repo"
      github_cr_pullthrough_cache_rule = {
        enabled = true
        upstream_repository_prefix = "my-prefix"
        credential_arn = "arn:aws:iam::123456789012:role/my-role"
      }
    }

     assert {
      condition = length(aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule) == 1
      error_message = "Pullthrough cache rule was not created, but should  be"
    }

    assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["github"].ecr_repository_prefix == "ROOT"
      error_message = "Invalid ECR repository prefix"
    }

    assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["github"].upstream_repository_prefix == "my-prefix"
      error_message = "Invalid upstream repository prefix"
    }

     assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["github"].credential_arn == "arn:aws:iam::123456789012:role/my-role"
      error_message = "Invalid credential ARN"
    }
}

run "rule_override_creates_gitlab_cr_rule" {
   command = plan

    variables {
      repository_name = "test-repo"
      gitlab_cr_pullthrough_cache_rule = {
        enabled = true
        upstream_repository_prefix = "my-prefix"
        credential_arn = "arn:aws:iam::123456789012:role/my-role"
      }
    }

     assert {
      condition = length(aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule) == 1
      error_message = "Pullthrough cache rule was not created, but should  be"
    }

    assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["gitlab"].ecr_repository_prefix == "ROOT"
      error_message = "Invalid ECR repository prefix"
    }

    assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["gitlab"].upstream_repository_prefix == "my-prefix"
      error_message = "Invalid upstream repository prefix"
    }

     assert {
      condition = aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule["gitlab"].credential_arn == "arn:aws:iam::123456789012:role/my-role"
      error_message = "Invalid credential ARN"
    }
}

run "custom_rule_should_be_created_when_specified" {
    command = plan

    variables {
      repository_name = "test-repo"
      pullthrough_cache_rules = [
        {
            upstream_repository_prefix = "my-prefix"
            upstream_registry_url = "my-registry.example.com"
        }
      ]
    }

    assert {
      condition = length(aws_ecr_pull_through_cache_rule.custom_pullthrough_cache_rule) == 1
      error_message = "Custom rule not created, but should be"
    }
}

run "should_create_both_default_and_custom_rules" {
    command = plan

    variables {
      repository_name = "test-repo"
       docker_hub_pullthrough_cache_rule = {
        enabled = true
        upstream_repository_prefix = "my-prefix"
        credential_arn = "arn:aws:iam::123456789012:role/my-role"
      }
       github_cr_pullthrough_cache_rule = {
        enabled = true
        upstream_repository_prefix = "my-prefix"
        credential_arn = "arn:aws:iam::123456789012:role/my-role"
      }
      pullthrough_cache_rules = [
        {
            upstream_repository_prefix = "my-prefix"
            upstream_registry_url = "my-registry.example.com"
        }
      ]
    }

    assert {
      condition = contains(keys(aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule),"docker_hub")
      error_message = "Docker Hub rule not created, but should be"
    }   

     assert {
      condition = contains(keys(aws_ecr_pull_through_cache_rule.default_pullthrough_cache_rule),"github")
      error_message = "Github rule not created, but should be"
    }  

      assert {
      condition = length(aws_ecr_pull_through_cache_rule.custom_pullthrough_cache_rule) == 1
      error_message = "Custom rule not created, but should be"
    }   
}
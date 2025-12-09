# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  
}

run "registry_policy_is_created_when_policy_file_path_provided" {
    command = apply

    variables {
      repository_name = "test-repo"
      registry_policy_path = "tests/test-policy.json"
    }

    assert {
      condition = length(aws_ecr_registry_policy.registry_policy) == 1
      error_message = "The registry policy was not created."
    }

    assert {
      
      condition = aws_ecr_registry_policy.registry_policy[0].registry_id != ""
      error_message = "reigstry_id was not set"
    }

}

run "registry_policy_not_created_when_policy_file_path_not_provided" {
    command = plan

    variables {
      repository_name = "test-repo"
    }   

    assert {
      condition = length(aws_ecr_registry_policy.registry_policy) == 0
      error_message = "The registry policy was created."
    }

}

run "repostitory_policy_should_be_created_when_policy_file_path_provided" {
    command = apply

    variables {
      repository_name = "test-repo"
      repo_policy_path = "tests/test-policy.json"
    }

    assert {
      condition = length(aws_ecr_repository_policy.repo_policy) == 1
      error_message = "The repository policy was not created."
    }

    assert {
      condition = aws_ecr_repository_policy.repo_policy[0].registry_id != ""
      error_message = "reigstry_id was not set"
    }
}

run "repo_lifecycle_policy_should_be_created_when_policy_file_path_provided" {
    command = apply

    variables {
      repository_name = "test-repo"
      repo_lifecycle_policy_path = "tests/test-policy.json"
    }

    assert {        
        condition = length(aws_ecr_lifecycle_policy.repo_lifecycle_policy) == 1
        error_message = "The lifecycle policy was not created."
    }

}

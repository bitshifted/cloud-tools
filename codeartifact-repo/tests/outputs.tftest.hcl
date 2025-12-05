# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  override_resource {
    target = aws_codeartifact_domain.repo_domain
    values = {
      arn   = "arn:aws:codeartifact:us-east-1:123456789012:domain/test-domain"
      owner = "123456789012"
  }
  }
  override_data {
    target = data.aws_region.current_region
    values = {
      region = "us-east-1"
    }
  }
}

run "correct_output_should_be_generated" {
    command = apply

    variables {
      domain_name = "test-domain"
      repositories = [
        {
            repository_name = "repo-name"
            external_connection = "public:npmjs"
        }
      ]
    }

    assert {
      condition = output.domain == "test-domain" && output.domain_owner == aws_codeartifact_domain.repo_domain.owner && output.repo_urls["repo-name"] == "https://test-domain-123456789012.d.codeartifact.us-east-1.amazonaws.com" 
      error_message = "Outputs did not match expected values."
    }
}

run "correct_output_with_multiple_repositories" {
    command = apply

    variables {
      domain_name = "test-domain"
      repositories = [
        {
            repository_name = "repo-one"
        },
        {
            repository_name = "repo-two"
        }
      ]
    }

    assert {
      condition = output.domain == "test-domain" && output.domain_owner == aws_codeartifact_domain.repo_domain.owner && output.repo_urls["repo-one"] == "https://test-domain-123456789012.d.codeartifact.us-east-1.amazonaws.com" && output.repo_urls["repo-two"] == "https://test-domain-123456789012.d.codeartifact.us-east-1.amazonaws.com"
      error_message = "Outputs did not match expected values for multiple repositories."
    }
}

run "correct_urls_with_different_region" {
    command = apply

    variables {
      domain_name = "test-domain"
      repo_region = "us-west-2"
      repositories = [
        {
            repository_name = "repo-name"
        }
      ]
    }

    assert {
      condition = output.domain == "test-domain" && output.domain_owner == aws_codeartifact_domain.repo_domain.owner && output.repo_urls["repo-name"] == "https://test-domain-123456789012.d.codeartifact.us-west-2.amazonaws.com"
      error_message = "Output URLs did not match expected values for specified repository region."
    }
}
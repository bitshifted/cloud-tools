// Copyright 2025 Bitshift
// SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {}

run "default_policy_should_be_created_when_principals_specified" {
  command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
        {
            repository_name                 = "repo-with-policies"
            default_read_access_principals  = ["arn:aws:iam::123456789012:role/ReadRole"]
            default_write_access_principals = ["arn:aws:iam::123456789012:role/WriteRole"]
        }
        ]
    }

    assert {
      condition     = length(data.aws_iam_policy_document.default_readonly_repo_policy) == 1
      error_message = "Default read-only policy document was not created."
    }

    assert {
      condition     = length(data.aws_iam_policy_document.default_write_access_repo_policy) == 1
      error_message = "Default write-access policy document was not created."
    }
}

run "no_default_policy_when_no_principals" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
        {
            repository_name = "repo-without-policies"
        }
        ]
    }

    assert {
      condition     = length(data.aws_iam_policy_document.default_readonly_repo_policy) == 0
      error_message = "Default read-only policy document was created despite no principals being specified."
    }

    assert {
      condition     = length(data.aws_iam_policy_document.default_write_access_repo_policy) == 0
      error_message = "Default write-access policy document was created despite no principals being specified."
    }
}

run "combined_policy_created_when_either_principal_specified" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
        {
            repository_name                 = "repo-with-read-policy"
            default_read_access_principals  = ["arn:aws:iam::123456789012:role/ReadRole"]
        },
        {
            repository_name                 = "repo-with-write-policy"
            default_write_access_principals = ["arn:aws:iam::123456789012:role/WriteRole"]
        }
        ]
    }

    assert {
      condition     = length(data.aws_iam_policy_document.combined_default_policies) == 2
      error_message = "Combined default policies were not created correctly when either read or write principals were specified."
    }
}

run "no_combined_policy_when_no_principals" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
        {
            repository_name = "repo-without-policies"
        }
        ]
    }

    assert {
      condition     = length(data.aws_iam_policy_document.combined_default_policies) == 0
      error_message = "Combined default policy was created despite no principals being specified."
    }
}

run "policy_file_should_override_default_policy" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
        {
            repository_name      = "repo-with-policy-file"
            policy_document_path = "tests/test-repo-policy.json"
            default_read_access_principals  = ["arn:aws:iam::123456789012:role/ReadRole"]
        }
        ]
    }

    assert {
      condition     = length(aws_codeartifact_repository_permissions_policy.repo_permissions_policy) == 1
      error_message = "Repository permissions policy was not created when a policy document path was provided."
    }
}
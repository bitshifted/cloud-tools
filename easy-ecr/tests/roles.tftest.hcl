# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  override_data {
    target = data.aws_iam_policy_document.assume_pull_role_document
    values = {
      json = "{}"
    }
  }
  override_data {
    target = data.aws_iam_policy_document.pull_only_policy_document
    values = {
      json = "{}"
    }
  }
}

run "roles_should_not_be_created_when_no_principals" {
    command = apply

    variables {
      repository_name = "test-repo"
    }

    assert {
      condition = length(aws_iam_role.repo_read_only_role) == 0
      error_message = "Read only role is created when no principals specified"
    }

    assert {
      condition = length(aws_iam_role.repo_push_role) == 0
      error_message = "Push is created when no principals specified"
    }
}

run "read_only_role_is_created_when_principals_are_specified" { 
     command = apply

    variables {
      repository_name = "test-repo"
      pull_only_principals = ["arn:aws:iam::/user/user1"]
    }

     assert {
      condition = length(aws_iam_role.repo_read_only_role) == 1
      error_message = "Read only role is  notcreated when principals are specified"
    }
}
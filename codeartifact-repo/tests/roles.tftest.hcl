// Copyright 2025 Bitshift
// SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  override_data {
    target = data.aws_iam_policy_document.read_only_policy_document
    values = {
      json = "{}"
    }
  }
  override_data {
    target = data.aws_iam_policy_document.assume_read_only_role_document
    values = {
      json = "{}"
    }
  }
  override_data {
    target = data.aws_iam_policy_document.assume_publisher_role_document
    values = {
      json = "{}"
    }
  }
}

run "read_access_role_should_be_created_when_specified" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
            {
                repository_name                 = "repo-with-read-role"
            }
        ]
        reader_principals  = ["arn:aws:iam::123456789012:role/ReadRole"]
    }

    assert {
      condition     = length(aws_iam_role.read_access_role) == 1
      error_message = "Default read-only policy document was not created when read access principals were specified."
    }
    assert {
      condition = length(aws_iam_role_policy.read_only_role_policy) == 1
      error_message = "Read access role policy was not created when read access principals were specified."
    }
}

run "no_read_access_role_when_no_principals" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
            {
                repository_name = "repo-without-read-role"
            }
        ]
    }

    assert {
      condition     = length(aws_iam_role.read_access_role) == 0
      error_message = "Read access role was created despite no read access principals being specified."
    }
     assert {
      condition = length(aws_iam_role_policy.read_only_role_policy) == 0
      error_message = "Read access role policy created when read access principals were not specified."
    }
}

run "publisher_access_role_should_be_created_when_specified" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
            {
                repository_name                 = "repo-with-publisher-role"
            }
        ]
        publisher_principals  = ["arn:aws:iam::123456789012:role/PublishRole"]
    }

    assert {
      condition     = length(aws_iam_role.publisher_access_role) == 1
      error_message = "Publisher access role was not created when publisher principals were specified."
    }
    assert {
      condition = length(aws_iam_role_policy.publisher_access_role_policy) == 1
      error_message = "Publisher access role policy was not created when publisher principals were specified."
    }
}
run "no_publisher_access_role_when_no_principals" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
            {
                repository_name = "repo-without-publisher-role"
            }
        ]
    }

    assert {
      condition     = length(aws_iam_role.publisher_access_role) == 0
      error_message = "Publisher access role was created despite no publisher principals being specified."
    }
     assert {
      condition = length(aws_iam_role_policy.publisher_access_role_policy) == 0
      error_message = "Publisher access role policy created when publisher principals were not specified."
    }
}
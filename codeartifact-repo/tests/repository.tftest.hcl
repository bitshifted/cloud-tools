// Copyright 2025 Bitshift
// SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {}

run "repositories_creation" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
            {
                repository_name = "repo-one"
                description     = "First test repository"
            },
            {
                repository_name = "repo-two"
                description     = "Second test repository"
            }
        ]
    }

    assert {
      condition     = length(aws_codeartifact_repository.repository) == 2
      error_message = "The expected number of repositories was not created."
    }

    assert {
      condition     = aws_codeartifact_repository.repository["repo-one"].description == "First test repository"
      error_message = "The description for repo-one was not set correctly."
    }

    assert {
      condition     = aws_codeartifact_repository.repository["repo-two"].description == "Second test repository"
      error_message = "The description for repo-two was not set correctly."
    }
}

run "no_repositories_created_when_list_is_empty" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = []
    }

    assert {
      condition     = length(aws_codeartifact_repository.repository) == 0
      error_message = "Repositories were created despite an empty repositories list."
    }
}

run "set_upstream_and_external_connection_when_provided" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
            {
                repository_name     = "repo-with-upstream-and-connection"
                upstream            = "upstream-repo"
                external_connection = "public:npmjs"
            }
        ]
    }

    assert {
      condition     = aws_codeartifact_repository.repository["repo-with-upstream-and-connection"].upstream[0].repository_name == "upstream-repo"
      error_message = "The upstream repository was not set correctly."
    }

    assert {
      condition     = aws_codeartifact_repository.repository["repo-with-upstream-and-connection"].external_connections[0].external_connection_name == "public:npmjs"
      error_message = "The external connection was not set correctly."
    }
}

run "create_repository_permissions_policy_when_path_is_provided" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
            {
                repository_name      = "repo-with-policy"
                policy_document_path = "tests/test-repo-policy.json"
            }
        ]
    }

    assert {
      condition     = length(aws_codeartifact_repository_permissions_policy.repo_permissions_policy) == 1
      error_message = "The repository permissions policy was not created when a valid policy document path was provided."
    }
}

run "output_should_return_created_repository_names" {
    command = plan

    variables  {
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
      condition     = contains(output.created_repositories, "repo-one") && contains(output.created_repositories, "repo-two")
      error_message = "The output 'created_repositories' does not contain the expected repository names."
    }
}

run "validate_external_connection_value" {
    command = plan

    variables  {
        domain_name = "test-domain"
        repositories = [
            {
                repository_name     = "repo-with-invalid-connection"
                external_connection = "invalid-connection"
            }
        ]
    }

    expect_failures = [ var.repositories[0].external_connection ]
}
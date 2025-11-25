// Copyright 2025 Bitshift
// SPDX-License-Identifier: MPL-2.0


mock_provider "aws" {
  
}

run "invalid_encryption_key_arn_should_produce_error" {
    command = plan

    variables  {
        use_default_ecnryption_key = false
        encryption_key_arn        = "invalid-arn"
        domain_name               = "test-domain"
    }
    expect_failures = [ 
        var.encryption_key_arn
     ]
}

run "invalid_encryption_key_arn_with_default_key_should_not_produce_error" {
    command = plan

    variables  {
        use_default_ecnryption_key = true
        encryption_key_arn        = "invalid-arn"
        domain_name               = "test-domain"
    }

    assert {
      condition     = aws_codeartifact_domain.repo_domain.domain == "test-domain"
      error_message = "An error was produced despite using the default encryption key."
    }

    assert {
      condition = length(aws_kms_key.domain_encryption_key) == 0
      error_message = "A KMS key was created despite using the default encryption key."
    }
}


run "custom_encryption_key_is_set_correctly" {
    command = plan

    variables {
        use_default_ecnryption_key = false
        # A valid-looking ARN for testing purposes.
        encryption_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/1234a567-bcde-890f-1234-56789a01b213"
        domain_name               = "test-domain-with-custom-key"
    }

    assert {
      condition     = aws_codeartifact_domain.repo_domain.encryption_key == "arn:aws:kms:us-east-1:123456789012:key/1234a567-bcde-890f-1234-56789a01b213"
      error_message = "The custom encryption key ARN was not assigned correctly."
    }

    assert {
      condition = length(aws_kms_key.domain_encryption_key) == 0
      error_message = "A KMS key was created despite using the default encryption key."
    }
}

run "create_kms_key_when_no_custom_key_and_default_not_used" {
    command = plan

    variables {
        use_default_ecnryption_key = false
        encryption_key_arn        = null
        domain_name               = "test-domain-with-new-key"
    }

    assert {
      condition = length(aws_kms_key.domain_encryption_key) == 1
      error_message = "A KMS key was not created when no custom key was provided and default key usage was disabled."
    }
}

run "policy_is_applied_to_created_kms_key" {
    command = plan

    variables {
        use_default_ecnryption_key        = false
        encryption_key_arn               = null
        domain_name                      = "test-domain-with-kms-policy"
        domain_encryption_key_policy_path = "tests/test-kms-key-policy.json"
    }

    assert {
      condition = length(aws_kms_key.domain_encryption_key) == 1
      error_message = "A KMS key was not created when no custom key was provided and default key usage was disabled."
    }

    assert {
      condition = aws_kms_key.domain_encryption_key[0].policy != null
      error_message = "IAM policy was not applie to created KMS key"
    }
}

run "tags_are_set_correctly" {
    command = plan

    variables {
        domain_name = "test-domain-with-tags"
        tags = {
            Environment = "Test"
            Project     = "CodeArtifactRepo"
        }
    }

    assert {
      condition     = aws_codeartifact_domain.repo_domain.tags["Environment"] == "Test" && aws_codeartifact_domain.repo_domain.tags["Project"] == "CodeArtifactRepo"
      error_message = "Tags were not assigned correctly to the CodeArtifact domain."
    }
}

run "set_correct_region_when_repo_region_is_provided" {
    command = plan

    variables {
        domain_name = "test-domain-in-region"
        repo_region = "us-west-2"
    }

    assert {
      condition     = aws_codeartifact_domain.repo_domain.region == "us-west-2"
      error_message = "The repository region was not set correctly."
    }
}

run "domain_permissions_policy_is_created_when_path_is_provided" {
    command = plan

    variables {
        domain_name                 = "test-domain-with-policy"
        domain_policy_document_path = "tests/test-domain-policy.json"
    }

    assert {
      condition     = length(aws_codeartifact_domain_permissions_policy.domain_permissions_policy) == 1
      error_message = "The domain permissions policy was not created when a valid policy document path was provided."
    }
}

run "domain_permissions_policy_is_not_created_when_path_is_not_provided" {
    command = plan

    variables {
        domain_name = "test-domain-without-policy"
    }

    assert {
      condition     = length(aws_codeartifact_domain_permissions_policy.domain_permissions_policy) == 0
      error_message = "The domain permissions policy was created despite no policy document path being provided."
    }
}
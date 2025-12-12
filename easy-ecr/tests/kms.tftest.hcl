# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  
}

run "kms_key_should_be_created_when_specified" {
    command = plan

    variables  {
        use_default_ecnryption_key = false
        encryption_key_arn        = null
        repository_name           = "test-repo"
    }

    assert {
      condition     = length(aws_kms_key.domain_encryption_key) == 1
      error_message = "KMS key was not created when use_default_ecnryption_key is false and encryption_key_arn is null."
    }
}

run "specific_kms_key_should_be_used_when_specified" {
    command = plan

    variables  {
        use_default_ecnryption_key = false
        encryption_key_arn        = "arn:aws:kms:us-west-2:123456789012:key/abcd-efgh-ijkl-mnop"
        repository_name           = "test-repo"
    }

    assert {
      condition     = length(aws_kms_key.domain_encryption_key) == 0
      error_message = "KMS key was created despite encryption_key_arn being specified."
    }
}

run "default_kms_key_should_be_used_when_specified" {
    command = plan

    variables  {
        repository_name           = "test-repo"
    }

    assert {
      condition     = length(aws_kms_key.domain_encryption_key) == 0
      error_message = "KMS key was created despite use_default_ecnryption_key being true."
    }
}
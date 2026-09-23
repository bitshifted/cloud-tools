# Copyright 2026 Bitshift ED (https://www.bitshifted.com)

mock_provider "aws" {
  override_resource {
    target = aws_kms_key.db_encryption_key[0]
    values = {
      arn    = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
      key_id = "00000000-0000-0000-0000-000000000000"
    }
  }
  override_data {
    target = data.aws_iam_policy_document.kms_key_policy[0]
    values = {
      json = "{\"Statement\":[{\"Sid\":\"Enable IAM User Permissions\",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":[\"arn:aws:iam::123456789012:root\"]},\"Action\":[\"kms:*\"]},{\"Sid\":\"Allow DynamoDB Service Access\",\"Effect\":\"Allow\",\"Principal\":{\"Service\":[\"dynamodb.amazonaws.com\"]},\"Action\":[\"kms:Encrypt\",\"kms:Decrypt\",\"kms:ReEncrypt*\",\"kms:GenerateDataKey*\",\"kms:DescribeKey\"]}]}"
    }
  }
}

variables {
  table_name         = "test-table"
  hash_key_attribute = "id"
  attributes = [
    {
      attr_name = "id"
      attr_type = "S"
    }
  ]
  environment     = "test"
  revision         = "1.0.0"
}

run "verify_default_kms_policy" {
  command = apply

  assert {
    condition     = aws_kms_key.db_encryption_key[0].policy != null
    error_message = "KMS key must have a policy"
  }

  assert {
    condition     = length(jsondecode(aws_kms_key.db_encryption_key[0].policy).Statement) >= 2
    error_message = "KMS policy must have at least 2 statements (Root and Service)"
  }
}


run "verify_no_kms_resources_when_arn_provided" {
  command = plan

  variables {
    encryption_key_arn = "arn:aws:kms:us-east-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  }

  assert {
    condition     = length(aws_kms_key.db_encryption_key) == 0
    error_message = "KMS key resource should not be created when encryption_key_arn is provided"
  }

  assert {
    condition     = length(data.aws_iam_policy_document.kms_key_policy) == 0
    error_message = "KMS policy data source should not be evaluated when encryption_key_arn is provided"
  }
}

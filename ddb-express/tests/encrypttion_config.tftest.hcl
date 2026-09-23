// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

mock_provider "aws" {

  override_resource {
    target = aws_kms_key.db_encryption_key[0]
    values = {
      arn    = "arn:aws:kms:us-east-1:123456789012:key/00000000-0000-0000-0000-000000000000"
      key_id = "00000000-0000-0000-0000-000000000000"
    }
  }
}

run "invalid_encryption_key_arn" {
  command = plan

  variables {
    table_name = "test-table-invalid-kms-arn"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    environment     = "test"
    revision         = "1.0.0"
    hash_key_attribute   = "id"
    encryption_key_arn   = "invalid-arn"
  }

  expect_failures = [
    var.encryption_key_arn
  ]
}

run "valid_encryption_key_arn_uses_kms_key" {
  command = plan

  variables {
    table_name = "test-table-valid-kms-arn"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    environment     = "test"
    revision         = "1.0.0"
    hash_key_attribute   = "id"
    encryption_key_arn   = "arn:aws:kms:us-east-1:123456789012:key/01234567-89ab-cdef-0123-456789abcdef"
  }

  assert {
    condition     = aws_dynamodb_table.db_table.server_side_encryption[0].enabled == true && aws_dynamodb_table.db_table.server_side_encryption[0].kms_key_arn == "arn:aws:kms:us-east-1:123456789012:key/01234567-89ab-cdef-0123-456789abcdef"
    error_message = "DynamoDB table encryption should be enabled and use the specified KMS key ARN."
  }
}

run "no_encryption_key_arn_creates_kms_key" {
  command = apply

  variables {
    table_name = "test-table-no-kms-arn"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    hash_key_attribute = "id"
    encryption_key_arn = null
    environment     = "test"
    revision         = "1.0.0"
  }

  assert {
    condition     = length(aws_kms_key.db_encryption_key) == 1
    error_message = "KMS key should be created when encryption_key_arn is null."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.server_side_encryption[0].kms_key_arn == aws_kms_key.db_encryption_key[0].arn
    error_message = "DynamoDB table should use the newly created KMS key ARN."
  }
}

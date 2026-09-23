// Copyright 2026 Bitshift ED (https://www.bitshifted.com)


mock_provider "aws" {
  
}

variables {
  table_name = "test-table-ttl"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      },
      {
        attr_name = "expiry"
        attr_type = "N"
      }
    ]
    hash_key_attribute = "id"
    ttl_attribute      = "expiry"
    environment        = "test"
    revision           = "1.0.0"
}

run "seed_data_not_applied_by_default" {
  command = plan
    assert {
        condition     = length(terraform_data.db_seeder) == 0
        error_message = "Seed data should not be applied when seed_data_file_path variable is not set."
    }
}

run "seed_data_applied_when_configured" {
  command = plan
    variables {
        seed_data_file_path = "tests/test_seed_data.json"
    }
    assert {
        condition     = length(terraform_data.db_seeder) == 1
        error_message = "Seed data should be applied when seed_data_file_path variable is set."
    }

    assert {
      condition     = terraform_data.db_seeder[0].triggers_replace.file_hash != null && length(terraform_data.db_seeder[0].triggers_replace.file_hash) == 64
      error_message = "File hash should be a valid SHA-256 hash of the seed data"
    }
}

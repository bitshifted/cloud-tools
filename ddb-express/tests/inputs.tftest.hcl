// Copyright 2026 Bitshift ED (https://www.bitshifted.com)


mock_provider "aws" {
  
}

run "invalid_billing_mode" {
  command = plan

  variables {
    table_name = "test-table-invalid-billing"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    hash_key_attribute = "id"
    capacity_config = {
      billing_mode = "INVALID_MODE"
    }
    environment     = "test"
    revision         = "1.0.0"
  }
  

  expect_failures = [
    var.capacity_config
  ]
}

run "invalid_attribute_type" {
  command = plan

  variables {
    table_name = "test-table-invalid-attr"
    attributes = [
      {
        attr_name = "id"
        attr_type = "X" # Invalid
      }
    ]
    environment     = "test"
    revision         = "1.0.0"
    hash_key_attribute = "id"
  }

  expect_failures = [
    var.attributes
  ]
}

run "invalid_hash_key" {
  command = plan

  variables {
    table_name = "test-table-invalid-hash-key"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    environment     = "test"
    revision         = "1.0.0"
    hash_key_attribute = "invalid_hash_key"
  }

  expect_failures = [
    var.hash_key_attribute
  ]
}

run "invalid_range_key" {
  command = plan

  variables {
    table_name = "test-table-invalid-range-key"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    hash_key_attribute = "id"
    range_key_attribute = "invalid_range_key"
    environment     = "test"
    revision         = "1.0.0"
  }

  expect_failures = [
    var.range_key_attribute
  ]
}

run "invalid_stream_view_type" {
  command = plan

  variables {
    table_name = "test-table-invalid-stream-view"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    hash_key_attribute = "id"
    stream_view_type   = "INVALID_STREAM_VIEW_TYPE"
    environment     = "test"
    revision         = "1.0.0"
  }

  expect_failures = [
    var.stream_view_type
  ]
}


// Copyright 2026 Bitshift ED (https://www.bitshifted.com)


mock_provider "aws" {

}

run "TTL_is_set_when_variable_configured" {
  command = plan

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

  assert {
    condition     = aws_dynamodb_table.db_table.ttl[0].enabled == true && aws_dynamodb_table.db_table.ttl[0].attribute_name == "expiry"
    error_message = "TTL settings were not configured correctly when ttl_attribute variable is set."
  }
}

run "Table_tags_match_stack_variables" {
  command = plan

  variables {
    table_name = "test-table-tags"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    hash_key_attribute = "id"
    environment        = "test"
    revision           = "1.0.0"
  }

  assert {
    condition     = aws_dynamodb_table.db_table.tags["Environment"] == "test" && aws_dynamodb_table.db_table.tags["Version"] == "1.0.0"
    error_message = "DynamoDB table tags should contain Environment and Version from stack variables."
  }
}

run "Table_created_with_sort_key_when_configured" {
  command = plan

  variables {
    table_name = "test-table-sort-key"
    attributes = [
      {
        attr_name = "OrderID"
        attr_type = "S"
      },
      {
        attr_name = "OrderDate"
        attr_type = "S"
      }
    ]
    hash_key_attribute  = "OrderID"
    range_key_attribute = "OrderDate"
    environment         = "test"
    revision            = "1.0.0"
  }

  assert {
    condition     = aws_dynamodb_table.db_table.range_key == "OrderDate"
    error_message = "Table range key was not configured correctly."
  }
}

run "Table_created_with_single_lsi" {
  command = plan

  variables {
    table_name = "test-table-lsi"
    attributes = [
      { attr_name = "OrderID", attr_type = "S" },
      { attr_name = "OrderDate", attr_type = "S" },
      { attr_name = "Status", attr_type = "S" }
    ]
    hash_key_attribute  = "OrderID"
    range_key_attribute = "OrderDate"

    lsi_list = [
      {
        name            = "StatusIndex"
        range_key       = "Status"
        projection_type = "ALL"
      }
    ]
    environment = "test"
    revision    = "1.0.0"
  }

  assert {
    condition     = length(aws_dynamodb_table.db_table.local_secondary_index) == 1
    error_message = "Table should have 1 Local Secondary Index."
  }

  assert {
    condition     = contains([for index in aws_dynamodb_table.db_table.local_secondary_index : index.name], "StatusIndex")
    error_message = "LSI StatusIndex was not created."
  }

  assert {
    condition     = contains([for index in aws_dynamodb_table.db_table.local_secondary_index : index.range_key], "Status")
    error_message = "LSI StatusIndex has incorrect range key."
  }
}

run "Table_created_with_multiple_lsis" {
  command = plan

  variables {
    table_name = "test-table-multiple-lsis"
    attributes = [
      { attr_name = "OrderID", attr_type = "S" },
      { attr_name = "OrderDate", attr_type = "S" },
      { attr_name = "Status", attr_type = "S" },
      { attr_name = "Category", attr_type = "S" }
    ]
    hash_key_attribute  = "OrderID"
    range_key_attribute = "OrderDate"

    lsi_list = [
      {
        name            = "StatusIndex"
        range_key       = "Status"
        projection_type = "ALL"
      },
      {
        name            = "CategoryIndex"
        range_key       = "Category"
        projection_type = "ALL"
      }
    ]
    environment = "test"
    revision    = "1.0.0"
  }

  assert {
    condition     = length(aws_dynamodb_table.db_table.local_secondary_index) == 2
    error_message = "Table should have 2 Local Secondary Indexes."
  }
}

run "Table_created_with_lsi_default_projection" {
  command = plan

  variables {
    table_name = "test-table-lsi-default"
    attributes = [
      { attr_name = "id", attr_type = "S" },
      { attr_name = "sk", attr_type = "S" },
      { attr_name = "lsi_sk", attr_type = "S" }
    ]
    hash_key_attribute  = "id"
    range_key_attribute = "sk"

    lsi_list = [
      {
        name      = "LSI_Default"
        range_key = "lsi_sk"
      }
    ]
    environment = "test"
    revision    = "1.0.0"
  }

  assert {
    condition     = one([for index in aws_dynamodb_table.db_table.local_secondary_index : index if index.name == "LSI_Default"]).projection_type == "ALL"
    error_message = "LSI projection type should default to ALL."
  }
}

run "Table_created_with_lsi_include_projection" {
  command = plan

  variables {
    table_name = "test-table-lsi-include"
    attributes = [
      { attr_name = "id", attr_type = "S" },
      { attr_name = "sk", attr_type = "S" },
      { attr_name = "lsi_sk", attr_type = "S" },
      { attr_name = "extra", attr_type = "S" }
    ]
    hash_key_attribute  = "id"
    range_key_attribute = "sk"

    lsi_list = [
      {
        name               = "LSI_Include"
        range_key          = "lsi_sk"
        projection_type    = "INCLUDE"
        non_key_attributes = ["extra"]
      }
    ]
    environment = "test"
    revision    = "1.0.0"
  }

  assert {
    condition     = one([for index in aws_dynamodb_table.db_table.local_secondary_index : index if index.name == "LSI_Include"]).projection_type == "INCLUDE"
    error_message = "LSI projection type should be INCLUDE."
  }

  assert {
    condition     = contains(one([for index in aws_dynamodb_table.db_table.local_secondary_index : index if index.name == "LSI_Include"]).non_key_attributes, "extra")
    error_message = "LSI non-key attributes should include 'extra'."
  }
}

run "stream_view_type_enables_stream" {
  command = apply

  variables {
    table_name = "test-table-stream"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    hash_key_attribute = "id"
    stream_view_type   = "NEW_IMAGE"
    environment        = "test"
    revision           = "1.0.0"
    encryption_key_arn = "arn:aws:kms:us-east-1:123456789012:key/01234567-89ab-cdef-0123-456789abcdef"
  }

  assert {
    condition     = aws_dynamodb_table.db_table.stream_enabled == true && aws_dynamodb_table.db_table.stream_view_type == "NEW_IMAGE"
    error_message = "DynamoDB stream should be enabled when stream_view_type is set."
  }
}

run "deletion_protection_enabled_by_default" {
  command = apply

  variables {
    table_name = "test-table-deletion-protection"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    hash_key_attribute       = "id"
    enable_delete_protection = true
    environment              = "test"
    revision                 = "1.0.0"
    encryption_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/01234567-89ab-cdef-0123-456789abcdef"
  }

  assert {
    condition     = aws_dynamodb_table.db_table.deletion_protection_enabled == true
    error_message = "DynamoDB deletion protection should be enabled when enable_delete_protection is set to true."
  }
}

run "on_demand_throughput_enabled" {
  command = apply

  variables {
    table_name = "test-table-on-demand"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    hash_key_attribute = "id"
    capacity_config = {
      billing_mode = "PAY_PER_REQUEST"
      on_demand_throughput = {
        max_read_request_units  = 1000
        max_write_request_units = 500
      }
    }
    environment        = "test"
    revision           = "1.0.0"
    encryption_key_arn = "arn:aws:kms:us-east-1:123456789012:key/01234567-89ab-cdef-0123-456789abcdef"
  }

  assert {
    condition     = aws_dynamodb_table.db_table.on_demand_throughput[0].max_read_request_units == 1000 && aws_dynamodb_table.db_table.on_demand_throughput[0].max_write_request_units == 500
    error_message = "DynamoDB on-demand throughput settings should be applied correctly."
  }
}

run "use_aws_managed_key_when_cmk_disabled" {
  command = apply

  variables {
    table_name = "test-table-aws-managed-key"
    attributes = [
      {
        attr_name = "id"
        attr_type = "S"
      }
    ]
    hash_key_attribute = "id"
    use_cmk_kms_key    = false
    environment        = "test"
    revision           = "1.0.0"
  }

  assert {
    condition     = length(aws_dynamodb_table.db_table.server_side_encryption) == 0
    error_message = "AWS managed key should be used when use_cmk_kms_key is set to false."
  }

  assert {
    condition     = length(aws_kms_key.db_encryption_key) == 0
    error_message = "No customer-managed KMS key should be created when use_cmk_kms_key is false."
  }
}
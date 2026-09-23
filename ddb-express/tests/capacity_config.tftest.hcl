// Copyright 2026 Bitshift ED (https://www.bitshifted.com)

mock_provider "aws" {
}

variables {
  table_name         = "test-capacity-config"
  environment        = "test"
  revision           = "1.0.0"
  hash_key_attribute = "id"
  attributes = [
    {
      attr_name = "id"
      attr_type = "S"
    }
  ]
}

run "defaults_to_pay_per_request_when_no_config" {
  command = plan

  assert {
    condition     = aws_dynamodb_table.db_table.billing_mode == "PAY_PER_REQUEST"
    error_message = "Default billing mode should be PAY_PER_REQUEST."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.table_class == "STANDARD"
    error_message = "Default table class should be STANDARD."
  }
}

run "provisioned_mode_with_custom_capacities" {
  command = plan

  variables {
    capacity_config = {
      billing_mode   = "PROVISIONED"
      read_capacity  = 10
      write_capacity = 20
    }
  }

  assert {
    condition     = aws_dynamodb_table.db_table.billing_mode == "PROVISIONED"
    error_message = "Billing mode should be PROVISIONED."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.read_capacity == 10
    error_message = "Read capacity should be 10."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.write_capacity == 20
    error_message = "Write capacity should be 20."
  }
}

run "provisioned_mode_with_default_capacities" {
  command = plan

  variables {
    capacity_config = {
      billing_mode = "PROVISIONED"
    }
  }

  assert {
    condition     = aws_dynamodb_table.db_table.read_capacity == 1
    error_message = "Default read capacity should be 1."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.write_capacity == 1
    error_message = "Default write capacity should be 1."
  }
}

run "on_demand_with_throughput_limits" {
  command = plan

  variables {
    capacity_config = {
      billing_mode = "PAY_PER_REQUEST"
      on_demand_throughput = {
        max_read_request_units  = 1000
        max_write_request_units = 500
      }
    }
  }

  assert {
    condition     = aws_dynamodb_table.db_table.on_demand_throughput[0].max_read_request_units == 1000
    error_message = "Max read request units should be 1000."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.on_demand_throughput[0].max_write_request_units == 500
    error_message = "Max write request units should be 500."
  }
}

run "on_demand_with_warm_throughput" {
  command = plan

  variables {
    capacity_config = {
      billing_mode = "PAY_PER_REQUEST"
      warm_throughput = {
        read_units_per_second  = 12000
        write_units_per_second = 4000
      }
    }
  }

  assert {
    condition     = aws_dynamodb_table.db_table.warm_throughput[0].read_units_per_second == 12000
    error_message = "Warm read units should be 12000."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.warm_throughput[0].write_units_per_second == 4000
    error_message = "Warm write units should be 4000."
  }
}

run "advanced_on_demand_from_quickstart" {
  command = plan

  variables {
    capacity_config = {
      billing_mode = "PAY_PER_REQUEST"
      table_class  = "STANDARD_INFREQUENT_ACCESS"

      on_demand_throughput = {
        max_read_request_units  = 10000
        max_write_request_units = 5000
      }

      warm_throughput = {
        read_units_per_second  = 12000
        write_units_per_second = 4000
      }
    }
  }

  assert {
    condition     = aws_dynamodb_table.db_table.billing_mode == "PAY_PER_REQUEST"
    error_message = "Billing mode should be PAY_PER_REQUEST."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.table_class == "STANDARD_INFREQUENT_ACCESS"
    error_message = "Table class should be STANDARD_INFREQUENT_ACCESS."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.on_demand_throughput[0].max_read_request_units == 10000
    error_message = "Max read request units should be 10000."
  }

  assert {
    condition     = aws_dynamodb_table.db_table.warm_throughput[0].read_units_per_second == 12000
    error_message = "Warm read units should be 12000."
  }
}

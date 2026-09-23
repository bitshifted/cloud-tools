// Copyright 2026 Bitshift ED (https://www.bitshifted.com)


mock_provider "aws" {
  
}

run "Point_in_time_recovery_enabled_by_default" {
    command = plan
    
    variables {
        table_name = "test-table-pitr"
        attributes = [
        {
            attr_name = "id"
            attr_type = "S"
        }
        ]
        hash_key_attribute = "id"
        recovery_period = 7
        environment     = "test"
        revision         = "1.0.0"
    }
    
    assert {
      condition = aws_dynamodb_table.db_table.point_in_time_recovery[0].enabled == true && aws_dynamodb_table.db_table.point_in_time_recovery[0].recovery_period_in_days == 7
      error_message = "Point-in-time recovery settings were not configured correctly when point_in_time_recovery_enabled variable is set."
    }
}

run "Point_in_time_recovery_disabled_when_variable_set_to_false" {
    command = plan
    
    variables {
        table_name = "test-table-pitr-disabled"
        attributes = [
        {
            attr_name = "id"
            attr_type = "S"
        }
        ]
        hash_key_attribute = "id"
        point_in_time_recovery_enabled = false
        environment     = "test"
        revision         = "1.0.0"
    }
    
    assert {
      condition = aws_dynamodb_table.db_table.point_in_time_recovery[0].enabled == false
      error_message = "Point-in-time recovery should be disabled when point_in_time_recovery_enabled variable is set to false."
    }
}


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

run "auto_scaling_not_enabled_for_ondemand_mode" {
  command = plan

  assert {
    condition = length(aws_appautoscaling_target.table_read_autoscaling_target) == 0
    error_message = "Auto scaling target should not be created for on-demand mode"
  }

  assert {
    condition = length(aws_appautoscaling_policy.table_read_autoscaling_policy) == 0
    error_message = "Auto scaling policy should not be created for on-demand mode"
  }
}

run "auto_scaling_enabled_for_provisioned_mode" {
  command = plan

  variables {
    capacity_config = {
      billing_mode   = "PROVISIONED"
      read_capacity  = 10
      write_capacity = 20
    }
  }

  assert {
    condition     = length(aws_appautoscaling_target.table_read_autoscaling_target) == 1
    error_message = "Auto scaling target should be created when auto scaling is enabled for provisioned mode"
  }

  assert {
    condition     = length(aws_appautoscaling_policy.table_read_autoscaling_policy) == 1
    error_message = "Auto scaling policy should be created when auto scaling is enabled for provisioned mode"
  }
}

run "auto_scaling_enabled_for_provisioned_mode_with_custom_values" {
  command = plan

  variables {
    capacity_config = {
      billing_mode   = "PROVISIONED"
      read_capacity  = 200
      write_capacity = 500
    }
    auto_scaling_config = {
      enabled = true
      read_config = {
        min_capacity = 100
        max_capacity = 5000
      }
    }
  }

  assert {
    condition     = length(aws_appautoscaling_target.table_read_autoscaling_target) == 1
    error_message = "Auto scaling target should be created when auto scaling is enabled for provisioned mode"
  }

  assert {
    condition     = length(aws_appautoscaling_policy.table_read_autoscaling_policy) == 1
    error_message = "Auto scaling policy should be created when auto scaling is enabled for provisioned mode"
  }

  assert {
    condition = aws_appautoscaling_target.table_read_autoscaling_target[0].min_capacity == 100
    error_message = "Invalid minimum capcity for auto scaling target"
  }

  assert {
    condition = aws_appautoscaling_target.table_read_autoscaling_target[0].max_capacity == 5000
    error_message = "Invalid maximum capacity for auto scaling target"
  }
}

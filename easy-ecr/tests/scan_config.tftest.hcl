# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  
}

run "default_scan_configuration_should_be_created" {
    command = plan

    variables {
      repository_name = "test-repo"
    }

    assert {
      condition = aws_ecr_account_setting.account_scan_config.name == "BASIC_SCAN_TYPE_VERSION"
      error_message = "Scan configuration resource was not created with correct name"
    }

    assert {
      condition = aws_ecr_account_setting.account_scan_config.value == "AWS_NATIVE"
      error_message = "Scan configuration resource was not created with correct value"
    }
}

run "default_scan_config_is_overriden_when_specified" {
  command = apply

  variables {
    repository_name = "test-repo"
    default_account_scan_config = {
      name = "BASIC_SCAN_TYPE_VERSION"
      value = "CLAIR"
    }
  }

   assert {
      condition = aws_ecr_account_setting.account_scan_config.name == "BASIC_SCAN_TYPE_VERSION"
      error_message = "Scan configuration resource was not created with correct name"
    }

    assert {
      condition = aws_ecr_account_setting.account_scan_config.value == "CLAIR"
      error_message = "Scan configuration resource was not created with correct value"
    }
}

run "scan_configuration_is_basic_by_default" {
  command = apply

  variables {
    repository_name = "test-repo"
  }

  assert {
    condition = aws_ecr_registry_scanning_configuration.registry_scan_config.scan_type == "BASIC"
    error_message = "Scanning configuration is not BASIC"
  }
  assert {
    condition = length(aws_ecr_registry_scanning_configuration.registry_scan_config.rule) == 0
    error_message = "Rules list is not empty"
  }
}

run "scan_configuration_overrides_defaults" {
  command = apply

  variables {
    repository_name = "test-repo"
    registry_scan_configuration = {
      type = "ENHANCED"
      rules = [
        {
          frequency = "CONTINUOUS_SCAN"
          filter = "my-filter"
        }
      ]
    }
  }

   assert {
    condition = aws_ecr_registry_scanning_configuration.registry_scan_config.scan_type == "ENHANCED"
    error_message = "Scanning configuration is not ENHANCED"
  }
  assert {
    condition = length(aws_ecr_registry_scanning_configuration.registry_scan_config.rule) == 1
    error_message = "Rules list is empty"
  }

  assert {
    condition = length([for r in aws_ecr_registry_scanning_configuration.registry_scan_config.rule : r if r.scan_frequency == "CONTINUOUS_SCAN"]) == 1
    error_message = "Invalid scan configuration"
  }
}

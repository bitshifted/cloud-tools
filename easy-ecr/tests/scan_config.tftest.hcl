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

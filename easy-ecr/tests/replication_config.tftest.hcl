# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  override_data {
    target = data.aws_caller_identity.current
    values = {
      account_id = "123456789012"
    }
  }
}

run "no_replication_config_by_default" {
    command = apply

    variables {
      repository_name = "test-repo"
    }

    assert {
      condition = length(aws_ecr_replication_configuration.replication_config) == 0
      error_message = "Replication configuration is not empty"
    }
}

run "per_region_config_should_be_created" {
    command = plan

    variables {
      repository_name = "test-repo"
      replication_config = [
        {
            region = "us-east-1"
        },
        {
            region = "us-east-2"
            filter = "my-filter"
        }
      ]
    }

     assert {
      condition = length(aws_ecr_replication_configuration.replication_config) == 1
      error_message = "Replication configuration is empty"
    }
    assert {
      condition = aws_ecr_replication_configuration.replication_config[0].replication_configuration[0].rule[0].destination[0].region == "us-east-1"
      error_message = "Invalid replication configuration"
    }
    assert {
      condition = aws_ecr_replication_configuration.replication_config[0].replication_configuration[0].rule[0].destination[1].region == "us-east-2"
      error_message = "Invalid replication configuration"
    }
    assert {
      condition = aws_ecr_replication_configuration.replication_config[0].replication_configuration[0].rule[0].repository_filter[0].filter == "my-filter"
      error_message = "Invalid replication configuration (filter)"
    }
}
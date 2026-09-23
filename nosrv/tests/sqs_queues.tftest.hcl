# Copyright 2026 Bitshift ED (https://www.bitshifted.com)

mock_provider "aws" {}

run "setup" {
  module {
    source = "./tests/src"
  }
}

variables {
  environment = "dev"
  revision    = "1.0.0"
}

run "create_multiple_queues_with_shared_dlq" {
  command = apply

  variables {
    sqs_defs = {
      orders = {
        name = "orders"
      }
      notifications = {
        name = "notifications"
      }
    }
  }

  assert {
    condition     = aws_sqs_queue.shared_dlq[0].name == "sqs-shared-dlq-dev"
    error_message = "Shared DLQ name is incorrect"
  }

  assert {
    condition     = aws_sqs_queue.main["orders"].name == "orders-dev"
    error_message = "Orders queue name is incorrect"
  }

  assert {
    condition     = aws_sqs_queue.main["notifications"].name == "notifications-dev"
    error_message = "Notifications queue name is incorrect"
  }

  assert {
    condition     = jsondecode(aws_sqs_queue.main["orders"].redrive_policy).deadLetterTargetArn == aws_sqs_queue.shared_dlq[0].arn
    error_message = "Orders queue is not associated with shared DLQ"
  }

  assert {
    condition     = jsondecode(aws_sqs_queue.main["notifications"].redrive_policy).deadLetterTargetArn == aws_sqs_queue.shared_dlq[0].arn
    error_message = "Notifications queue is not associated with shared DLQ"
  }
}

run "verify_redrive_allow_policy" {
  command = apply

  variables {
    sqs_defs = {
      orders = {
        name    = "orders"
        use_dlq = true
      }
      analytics = {
        name    = "analytics"
        use_dlq = false
      }
    }
  }

  assert {
    condition     = length(aws_sqs_queue_redrive_allow_policy.shared_dlq) > 0
    error_message = "Redrive allow policy should exist"
  }

  assert {
    condition     = contains(jsondecode(aws_sqs_queue_redrive_allow_policy.shared_dlq[0].redrive_allow_policy).sourceQueueArns, aws_sqs_queue.main["orders"].arn)
    error_message = "Orders queue ARN should be in sourceQueueArns"
  }

  assert {
    condition     = !contains(jsondecode(aws_sqs_queue_redrive_allow_policy.shared_dlq[0].redrive_allow_policy).sourceQueueArns, aws_sqs_queue.main["analytics"].arn)
    error_message = "Analytics queue ARN should NOT be in sourceQueueArns"
  }
}

run "verify_custom_kms_key" {
  command = plan

  variables {
    sqs_kms_key_alias = "alias/custom-sqs-key"
    sqs_defs = {
      test = {
        name = "test"
      }
    }
  }

  assert {
    condition     = aws_sqs_queue.main["test"].kms_master_key_id == "alias/custom-sqs-key"
    error_message = "Custom KMS key alias was not applied to main queue"
  }

  assert {
    condition     = aws_sqs_queue.shared_dlq[0].kms_master_key_id == "alias/custom-sqs-key"
    error_message = "Custom KMS key alias was not applied to shared DLQ"
  }
}

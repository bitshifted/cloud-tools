# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  
}

run "invalid_encryption_key_arn_should_produce_error" {
    command = plan

    variables  {
        use_default_ecnryption_key = false
        encryption_key_arn        = "invalid-arn"
        repository_name           = "test-repo"
    }
    expect_failures = [ 
        var.encryption_key_arn
     ]
}

run "invalid_visibility_should_produce_error" {
    command = plan

    variables  {
        visibility      = "INVALID"
        repository_name = "test-repo"
    }
    expect_failures = [ 
        var.visibility
     ]
}

run "private_repository_is_created_correctly" {
    command = plan

    variables {
        visibility      = "PRIVATE"
        repository_name = "private-repo"
        scan_images_on_push = false
    }

    assert {
      condition     = aws_ecr_repository.ecr_private_repo[0].name == "private-repo"
      error_message = "The private ECR repository was not created with the correct name."
    }

    assert {
      condition = length(aws_ecrpublic_repository.ecr_public_repo) == 0
      error_message = "A public ECR repository was created despite visibility being set to PRIVATE."
    }

    assert {
      condition = !aws_ecr_repository.ecr_private_repo[0].image_scanning_configuration[0].scan_on_push
      error_message = "Image scan on push is enabled"
    }
}

run "image_tag_mutable_setting" {
    command = plan

    variables {
        visibility        = "PRIVATE"
        repository_name   = "mutable-repo"
        image_tag_mutable = false
    }

    assert {
      condition     = aws_ecr_repository.ecr_private_repo[0].image_tag_mutability == "IMMUTABLE"
      error_message = "The image tag mutability setting is incorrect."
    }
}

run "image_tag_mutable_with_exclusion_filters" {
    command = plan

    variables {
        visibility                 = "PRIVATE"
        repository_name            = "mutable-exclusion-repo"
        image_tag_mutable          = true
        mutability_exclusion_filters = ["latest*", "stable*"]
    }

    assert {
      condition     = aws_ecr_repository.ecr_private_repo[0].image_tag_mutability == "MUTABLE_WITH_EXCLUSION"
      error_message = "The image tag mutability with exclusion filters setting is incorrect."
    }

    assert {
            condition = length(aws_ecr_repository.ecr_private_repo[0].image_tag_mutability_exclusion_filter) == 2
            error_message = "Expected two image_tag_mutability_exclusion_filter blocks to be set."
        }
}
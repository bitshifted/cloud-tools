# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

mock_provider "aws" {
  
}

run "should_create_public_repository" {
    command = plan

    variables {
        visibility      = "PUBLIC"
        repository_name = "public-repo"
    }
    assert {
      condition     = length(aws_ecrpublic_repository.ecr_public_repo) == 1
      error_message = "The public ECR repository was not created with the correct name."
    }       
}

run "should_create_public_repo_with_catalog_data" {
    command = plan

    variables {
        visibility      = "PUBLIC"
        repository_name = "public-repo"
        public_catalog_data = {
            about = "About text"
            architectures = ["ARM 64", "x86-64"]
            description = "descritpion text"
            operating_systems = ["Linux"]
        }
    }
    assert {
      condition     = aws_ecrpublic_repository.ecr_public_repo[0].catalog_data[0].about_text == "About text"
      error_message = "Wrong about text"
    }

     assert {
      condition     = aws_ecrpublic_repository.ecr_public_repo[0].catalog_data[0].description == "descritpion text"
      error_message = "Wrong description text"
    }
}

run "should_fail_on_invalid_architectures_data" {
    command = plan

    variables {
        visibility      = "PUBLIC"
        repository_name = "public-repo"
        public_catalog_data = {
            architectures = ["INVALID"]
        }
    }
    expect_failures = [ 
        var.public_catalog_data.architectures
     ]
}

run "should_fail_on_invalie_operating_system" {
    command = plan

    variables {
      visibility      = "PUBLIC"
        repository_name = "public-repo"
        public_catalog_data = {
            architectures = ["x86-64", "ARM 64"]
            operating_systems = ["Mac Os"]
        }
    }
    expect_failures = [ var.public_catalog_data.operating_systems ]
}
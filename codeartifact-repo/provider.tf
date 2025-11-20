terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
      version = "6.21.0"
    }
  }

  backend "s3" {
    bucket = "tf-backend-kms-state-538219348660-eu-central-1"
    key = "test-tf/terraform.tfstate"
    region = "eu-central-1"
    use_lockfile = true
    assume_role = {
      role_arn = "arn:aws:iam::538219348660:role/tf-backend-kms-TerraformAdminRole"
    }
  }
}
# Copyright 2026 Bitshift ED (https://www.bitshifted.com)


terraform {
  required_version = ">= 1.14.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.40.0"
    }
  }
}
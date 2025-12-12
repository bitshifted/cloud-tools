# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0



locals {
  resolved_region       = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  should_create_kms_key = (!var.use_default_ecnryption_key && var.encryption_key_arn == null) ? true : false
  image_tag_mutability  = var.image_tag_mutable ? (length(var.mutability_exclusion_filters) > 0 ? "MUTABLE_WITH_EXCLUSION" : "MUTABLE") : (length(var.mutability_exclusion_filters) > 0 ? "IMMUTABLE_WITH_EXCLUSION" : "IMUTABLE")
}

data "aws_region" "current_region" {}

resource "aws_ecr_repository" "ecr_private_repo" {
  count                = var.visibility == "PRIVATE" ? 1 : 0
  name                 = var.repository_name
  region               = local.resolved_region
  force_delete         = var.force_delete
  image_tag_mutability = local.image_tag_mutability

  #checkov:skip=CKV_AWS_136: Using AWS-managed AES256 is acceptable if user enables it
  encryption_configuration {
    encryption_type = var.use_default_ecnryption_key ? "AES256" : "KMS"
    kms_key         = !var.use_default_ecnryption_key ? var.encryption_key_arn != null ? var.encryption_key_arn : aws_kms_key.domain_encryption_key[0].arn : null
  }

  dynamic "image_tag_mutability_exclusion_filter" {
    for_each = var.mutability_exclusion_filters
    content {
      filter      = image_tag_mutability_exclusion_filter.value
      filter_type = "WILDCARD"
    }
  }

  image_scanning_configuration {
    scan_on_push = var.scan_images_on_push
  }

  tags = var.tags
}

resource "aws_ecrpublic_repository" "ecr_public_repo" {
  count           = var.visibility == "PUBLIC" ? 1 : 0
  repository_name = var.repository_name
  region          = local.resolved_region

  catalog_data {
    about_text        = var.public_catalog_data.about
    architectures     = var.public_catalog_data.architectures
    description       = var.public_catalog_data.description
    logo_image_blob   = var.public_catalog_data.logo_image_path != null ? filebase64(var.public_catalog_data.logo_image_path) : null
    operating_systems = var.public_catalog_data.operating_systems
    usage_text        = var.public_catalog_data.usage
  }

  tags = var.tags
}

resource "aws_kms_key" "domain_encryption_key" {
  count               = local.should_create_kms_key ? 1 : 0
  description         = "KMS key for ECR repository domain ${var.repository_name}"
  enable_key_rotation = true
  policy              = var.domain_encryption_key_policy_path != null ? file(var.domain_encryption_key_policy_path) : null
  tags                = var.tags
}
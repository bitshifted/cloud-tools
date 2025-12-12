# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

locals {
  use_any_lifecycle_policy       = var.visibility == "PRIVATE" && (var.use_default_image_lifecycle_policy || var.image_lifecycle_policy_path != null)
  apply_default_lifecycle_policy = var.use_default_image_lifecycle_policy && var.image_lifecycle_policy_path == null
}

resource "aws_ecr_registry_policy" "registry_policy" {
  count  = var.registry_policy_path != null ? 1 : 0
  region = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  policy = file(var.registry_policy_path)
}

resource "aws_ecr_repository_policy" "repo_policy" {
  count      = var.repo_policy_path != null ? 1 : 0
  region     = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  repository = aws_ecr_repository.ecr_private_repo[0].name
  policy     = file(var.repo_policy_path)
}

resource "aws_ecr_lifecycle_policy" "repo_lifecycle_policy" {
  count      = local.use_any_lifecycle_policy ? 1 : 0
  region     = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  repository = aws_ecr_repository.ecr_private_repo[0].name
  policy     = local.apply_default_lifecycle_policy ? file("${path.module}/default-lifecycle-policy.json") : file(var.image_lifecycle_policy_path)
}

resource "aws_ecrpublic_repository_policy" "public_repo_policy" {
  count           = var.public_repo_policy_path != null ? 1 : 0
  region          = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  repository_name = aws_ecrpublic_repository.ecr_public_repo[0].id
  policy          = file(var.public_repo_policy_path)
}
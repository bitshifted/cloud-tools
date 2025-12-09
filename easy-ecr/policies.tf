# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0



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
  count      = var.repo_lifecycle_policy_path != null ? 1 : 0
  region     = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  repository = aws_ecr_repository.ecr_private_repo[0].name
  policy     = file(var.repo_lifecycle_policy_path)
}
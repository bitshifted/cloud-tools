# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

output "private_repository_url" {
  value = length(aws_ecr_repository.ecr_private_repo) > 0 ? aws_ecr_repository.ecr_private_repo[0].repository_url : ""
  description = "URL of the private repository"
}

output "private_repository_arn" {
    value = length(aws_ecr_repository.ecr_private_repo) > 0 ? aws_ecr_repository.ecr_private_repo[0].arn : ""
    description = "ARN of the private repository"
}


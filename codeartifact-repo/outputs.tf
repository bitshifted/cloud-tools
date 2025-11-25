# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0

output "domain" {
  description = "Name of the CodeArtifact domain"
  value       = aws_codeartifact_domain.repo_domain.domain
}

output "domain_owner" {
  description = "Owner account of the CodeArtifact domain"
  value       = aws_codeartifact_domain.repo_domain.owner
}

output "created_repositories" {
  description = "A list of names of the created repositories."
  value       = tolist(keys(aws_codeartifact_repository.repository))
}

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


output "repo_urls" {
  description = "A map of repository names to their repository endpoints."
  value       = { for repo_name, repo in aws_codeartifact_repository.repository : repo_name => "https://${var.domain_name}-${aws_codeartifact_domain.repo_domain.owner}.d.codeartifact.${local.resolved_region}.amazonaws.com" }
}
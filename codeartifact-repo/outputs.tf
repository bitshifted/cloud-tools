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

output "policy_documents" {
  description = "A map of repository names to their applied policy documents (if any)."
  value       = { for repo_name, repo_policy in aws_codeartifact_repository_permissions_policy.repo_permissions_policy : repo_name => repo_policy.policy_document }
}

output "default_sts_policies" {
  description = "Created STS policies"
  value       = { for repo_name, sts_policy in data.aws_iam_policy_document.default_sts_policy : repo_name => sts_policy.json }
}
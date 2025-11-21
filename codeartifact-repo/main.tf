

locals {
  should_create_kms_key = (!var.use_default_ecnryption_key && var.encryption_key_arn == null) ? true : false
  # encryption_key_to_use = local.should_create_kms_key ? aws_kms_key.repo_encryption_key.name  : null
}

resource "aws_codeartifact_domain" "repo_domain" {
  domain = var.domain_name
  region = var.repo_region != null ? var.repo_region : null
  encryption_key = var.use_default_ecnryption_key ? null : var.encryption_key_arn
  tags = var.tags
}

resource "aws_codeartifact_domain_permissions_policy" "domain_permissions_policy" {
  count = var.domain_policy_document_path != null ? 1 : 0
  domain = aws_codeartifact_domain.repo_domain.domain
  policy_document = file(var.domain_policy_document_path)
  region = var.repo_region != null ? var.repo_region : null
  domain_owner = var.domain_owner != null ? var.domain_owner : null
  policy_revision = var.domain_permissions_policy_revision != null ? var.domain_permissions_policy_revision : null
}

resource "aws_codeartifact_repository" "repository" {
  for_each = { for repo in var.repositories : repo.repository_name => repo }
  domain = aws_codeartifact_domain.repo_domain.domain
  repository = each.key
  description = each.value.description
  region = var.repo_region != null ? var.repo_region : null
  domain_owner = each.value.domain_owner != null ? each.value.domain_owner : null

  dynamic "upstream" {
    for_each = each.value.upstream != null ? [each.value.upstream] : []
    content {
      repository_name = upstream.value
    }
  }

  dynamic "external_connections" {
    for_each = each.value.external_connection != null ? [each.value.external_connection] : []
    content {
      external_connection_name = external_connections.value
    }
  }
  tags = var.tags
}

resource "aws_codeartifact_repository_permissions_policy" "repo_permissions_policy" {
  for_each = { for repo in var.repositories : repo.repository_name => repo if repo.policy_document_path != null }
  repository = aws_codeartifact_repository.repository[each.key].repository
  domain     = aws_codeartifact_domain.repo_domain.domain
  policy_document = file(each.value.policy_document_path)
  region = var.repo_region != null ? var.repo_region : null
  domain_owner = each.value.domain_owner != null ? each.value.domain_owner : null
}

resource "aws_kms_key" "domain_encryption_key" {
  count = local.should_create_kms_key ? 1 : 0
  description = "KMS key for CodeArtifact domain ${var.domain_name}"
  enable_key_rotation = true
  policy = var.domain_encryption_key_policy_path != null ? file(var.domain_encryption_key_policy_path) : null
  tags = var.tags
}
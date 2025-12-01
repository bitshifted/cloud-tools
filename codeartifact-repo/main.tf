# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0



locals {
  should_create_kms_key = (!var.use_default_ecnryption_key && var.encryption_key_arn == null) ? true : false

  repo_read_access_principals = {
    for repo in var.repositories : repo.repository_name => repo.default_read_access_principals
  }
  repo_write_access_principals = {
    for repo in var.repositories : repo.repository_name => repo.default_write_access_principals
  }
  repo_final_policy_documents = data.aws_iam_policy_document.combined_default_policies
  repos_with_policy_files = [
    for repo in var.repositories : repo.repository_name if repo.policy_document_path != null
  ]
  all_sts_principals = {
    for repo in var.repositories : repo.repository_name => distinct(concat(
      repo.default_read_access_principals != null ? repo.default_read_access_principals : [],
      repo.default_write_access_principals != null ? repo.default_write_access_principals : []
    ))
  }
}

resource "aws_codeartifact_domain" "repo_domain" {
  domain         = var.domain_name
  region         = var.repo_region != null ? var.repo_region : null
  encryption_key = var.use_default_ecnryption_key ? null : var.encryption_key_arn
  tags           = var.tags
}

resource "aws_codeartifact_domain_permissions_policy" "domain_permissions_policy" {
  count           = var.domain_policy_document_path != null ? 1 : 0
  domain          = aws_codeartifact_domain.repo_domain.domain
  policy_document = file(var.domain_policy_document_path)
  region          = var.repo_region != null ? var.repo_region : null
  domain_owner    = var.domain_owner != null ? var.domain_owner : null
  policy_revision = var.domain_permissions_policy_revision != null ? var.domain_permissions_policy_revision : null
}

resource "aws_codeartifact_repository" "repository" {
  for_each     = { for repo in var.repositories : repo.repository_name => repo }
  domain       = aws_codeartifact_domain.repo_domain.domain
  repository   = each.key
  description  = each.value.description
  region       = var.repo_region != null ? var.repo_region : null
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

data "aws_iam_policy_document" "default_readonly_repo_policy" {
  for_each = { for k, v in local.repo_read_access_principals : k => v if v != null }
  statement {
    effect = "Allow"
    actions = [
      "codeartifact:DescribePackageVersion",
      "codeartifact:DescribeRepository",
      "codeartifact:GetPackageVersionReadme",
      "codeartifact:GetRepositoryEndpoint",
      "codeartifact:ListPackageVersionAssets",
      "codeartifact:ListPackageVersionDependencies",
      "codeartifact:ListPackageVersions",
      "codeartifact:ListPackages",
      "codeartifact:ReadFromRepository"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = each.value
    }
  }
}

data "aws_iam_policy_document" "default_write_access_repo_policy" {
  for_each = { for k, v in local.repo_write_access_principals : k => v if v != null }
  statement {
    effect = "Allow"
    actions = [
      "codeartifact:DescribePackageVersion",
      "codeartifact:DescribeRepository",
      "codeartifact:GetPackageVersionReadme",
      "codeartifact:GetRepositoryEndpoint",
      "codeartifact:ListPackageVersionAssets",
      "codeartifact:ListPackageVersionDependencies",
      "codeartifact:ListPackageVersions",
      "codeartifact:ListPackages",
      "codeartifact:PublishPackageVersion",
      "codeartifact:PutPackageMetadata",
      "codeartifact:ReadFromRepository"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = each.value
    }
  }
}

data "aws_iam_policy_document" "default_sts_policy" {
  for_each = local.all_sts_principals
  statement {
    effect    = "Allow"
    actions   = ["sts:GetServiceBearerToken"]
    resources = [aws_codeartifact_repository.repository[each.key].arn]
    principals {
      type        = "AWS"
      identifiers = each.value
    }
    condition {
      variable = "sts:AWSServiceName"
      values   = ["codeartifact.amazonaws.com"]
      test     = "StringEquals"
    }
  }
}

data "aws_iam_policy_document" "combined_default_policies" {
  for_each = { for repo in var.repositories : repo.repository_name => repo if(local.repo_read_access_principals[repo.repository_name] != null || local.repo_write_access_principals[repo.repository_name] != null) && repo.policy_document_path == null }

  source_policy_documents = compact(
    [
      try(data.aws_iam_policy_document.default_readonly_repo_policy[each.key].json, null),
      try(data.aws_iam_policy_document.default_write_access_repo_policy[each.key].json, null)
    ]
  )
}

resource "aws_codeartifact_repository_permissions_policy" "repo_permissions_policy" {
  for_each        = { for repo in var.repositories : repo.repository_name => repo if repo.policy_document_path != null || contains(keys(local.repo_final_policy_documents), repo.repository_name) }
  repository      = aws_codeartifact_repository.repository[each.key].repository
  domain          = aws_codeartifact_domain.repo_domain.domain
  policy_document = each.value.policy_document_path != null ? file(each.value.policy_document_path) : local.repo_final_policy_documents[each.key].json
  region          = var.repo_region != null ? var.repo_region : null
  domain_owner    = each.value.domain_owner != null ? each.value.domain_owner : null
}

resource "aws_kms_key" "domain_encryption_key" {
  count               = local.should_create_kms_key ? 1 : 0
  description         = "KMS key for CodeArtifact domain ${var.domain_name}"
  enable_key_rotation = true
  policy              = var.domain_encryption_key_policy_path != null ? file(var.domain_encryption_key_policy_path) : null
  tags                = var.tags
}
# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0



locals {
  should_create_kms_key = (!var.use_default_ecnryption_key && var.encryption_key_arn == null) ? true : false
}

data "aws_caller_identity" "current" {}

# CodeArtifact domain acting as a container for repositories
resource "aws_codeartifact_domain" "repo_domain" {
  domain         = var.domain_name
  region         = var.repo_region != null ? var.repo_region : null
  encryption_key = var.use_default_ecnryption_key ? null : var.encryption_key_arn
  tags           = var.tags
}

# Optional  permissions policy applied to the created domain. Only created if a policy document path is provided.
resource "aws_codeartifact_domain_permissions_policy" "domain_permissions_policy" {
  count           = var.domain_policy_document_path != null ? 1 : 0
  domain          = aws_codeartifact_domain.repo_domain.domain
  policy_document = file(var.domain_policy_document_path)
  region          = var.repo_region != null ? var.repo_region : null
  domain_owner    = var.domain_owner != null ? var.domain_owner : null
  policy_revision = var.domain_permissions_policy_revision != null ? var.domain_permissions_policy_revision : null
}

# CodeArtifact repositories within the domain. Multiple repositories can be created by providing a list of repository configurations,
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

# Optional permissions policy applied to each repository. Only created if a policy document path is provided in the repository configuration.
resource "aws_codeartifact_repository_permissions_policy" "repo_permissions_policy" {
  for_each        = { for repo in var.repositories : repo.repository_name => repo if repo.policy_document_path != null }
  repository      = aws_codeartifact_repository.repository[each.key].repository
  domain          = aws_codeartifact_domain.repo_domain.domain
  policy_document = file(each.value.policy_document_path)
  region          = var.repo_region != null ? var.repo_region : null
  domain_owner    = each.value.domain_owner != null ? each.value.domain_owner : null
}

# Optional KMS key for domain encryption. Created only if no encryption key ARN is provided and default encryption key usage is disabled.
resource "aws_kms_key" "domain_encryption_key" {
  count               = local.should_create_kms_key ? 1 : 0
  description         = "KMS key for CodeArtifact domain ${var.domain_name}"
  enable_key_rotation = true
  policy              = var.domain_encryption_key_policy_path != null ? file(var.domain_encryption_key_policy_path) : null
  tags                = var.tags
}

data "aws_iam_policy_document" "read_only_policy_document" {
  count = var.reader_principals != null && length(var.reader_principals) > 0 ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "codeartifact:ReadFromRepository",
      "codeartifact:Get*",
      "codeartifact:Describe*",
      "codeartifact:List*"
    ]
    resources = [aws_codeartifact_domain.repo_domain.arn, "${aws_codeartifact_domain.repo_domain.arn}/*"]
  }
  statement {
    effect  = "Allow"
    actions = ["sts:GetServiceBearerToken"]
    resources = [
      aws_codeartifact_domain.repo_domain.arn,
      "${aws_codeartifact_domain.repo_domain.arn}/*",
      "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.read_access_role[0].name}/*"
    ]
    condition {
      variable = "sts:AWSServiceName"
      values   = ["codeartifact.amazonaws.com"]
      test     = "StringEquals"
    }
  }
}

data "aws_iam_policy_document" "assume_read_only_role_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.reader_principals
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "publisher_policy_document" {
  count = var.publisher_principals != null && length(var.publisher_principals) > 0 ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "codeartifact:ReadFromRepository",
      "codeartifact:Get*",
      "codeartifact:Describe*",
      "codeartifact:List*",
      "codeartifact:PublishPackageVersion",
      "codeartifact:PutPackageMetadata",
      "codeartifact:CreatePackageGroup",
      "coeedartifact:UpdatePackageGroup",
      "codeartifact:CopyPackageVersions"
    ]
    resources = [
      aws_codeartifact_domain.repo_domain.arn,
      "${aws_codeartifact_domain.repo_domain.arn}/*",
      replace("${aws_codeartifact_domain.repo_domain.arn}/*", ":domain/", ":package/")
    ]
  }
  statement {
    effect  = "Allow"
    actions = ["sts:GetServiceBearerToken"]
    resources = [
      aws_codeartifact_domain.repo_domain.arn,
      "${aws_codeartifact_domain.repo_domain.arn}/*",
      "arn:aws:sts::${data.aws_caller_identity.current.account_id}:assumed-role/${aws_iam_role.publisher_access_role[0].name}/*"
    ]
    condition {
      variable = "sts:AWSServiceName"
      values   = ["codeartifact.amazonaws.com"]
      test     = "StringEquals"
    }
  }
}

data "aws_iam_policy_document" "assume_publisher_role_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.publisher_principals
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "admin_policy_document" {
  count = var.admin_principals != null && length(var.admin_principals) > 0 ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "codeartifact:*",
    ]
    resources = ["*"]
  }
  statement {
    effect    = "Allow"
    actions   = ["sts:GetServiceBearerToken"]
    resources = ["*"]
    condition {
      variable = "sts:AWSServiceName"
      values   = ["codeartifact.amazonaws.com"]
      test     = "StringEquals"
    }
  }
}

data "aws_iam_policy_document" "assume_admin_role_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.admin_principals
    }
    actions = ["sts:AssumeRole"]
  }
}

# IAM role for read-only access to domain and repositories. This should be assumed by the provided reader principals. Not created if no reader principals are provided.
resource "aws_iam_role" "read_access_role" {
  count              = var.reader_principals != null && length(var.reader_principals) > 0 ? 1 : 0
  name               = "CodeArtifactReadAccessRole-${aws_codeartifact_domain.repo_domain.domain}"
  description        = "Role providing read access to CodeArtifact domain ${aws_codeartifact_domain.repo_domain.domain}"
  assume_role_policy = data.aws_iam_policy_document.assume_read_only_role_document.json
  tags               = var.tags
}

# IAM policy attaching read-only permissions to the read access role. Not created if no reader principals are provided.
resource "aws_iam_role_policy" "read_only_role_policy" {
  count  = var.reader_principals != null && length(var.reader_principals) > 0 ? 1 : 0
  policy = data.aws_iam_policy_document.read_only_policy_document[0].json
  role   = aws_iam_role.read_access_role[0].name
}

# IAM role for publisher access to domain and repositories. This should be assumed by the provided publisher principals. Not created if no publisher principals are provided.
# Publishers are allowed to publish packages in addition to read-only access.
resource "aws_iam_role" "publisher_access_role" {
  count              = var.publisher_principals != null && length(var.publisher_principals) > 0 ? 1 : 0
  name               = "CodeArtifactPublisherAccessRole-${aws_codeartifact_domain.repo_domain.domain}"
  description        = "Role providing publisher access to CodeArtifact domain ${aws_codeartifact_domain.repo_domain.domain}"
  assume_role_policy = data.aws_iam_policy_document.assume_publisher_role_document.json
  tags               = var.tags
}

# IAM policy attaching publisher permissions to the publisher access role. Not created if no publisher principals are provided.
resource "aws_iam_role_policy" "publisher_access_role_policy" {
  count  = var.publisher_principals != null && length(var.publisher_principals) > 0 ? 1 : 0
  policy = data.aws_iam_policy_document.publisher_policy_document[0].json
  role   = aws_iam_role.publisher_access_role[0].name
}

# IAM role for admin access to domain and repositories. This should be assumed by the provided admin principals. Not created if no admin principals are provided.
resource "aws_iam_role" "admin_access_role" {
  count              = var.admin_principals != null && length(var.admin_principals) > 0 ? 1 : 0
  name               = "CodeArtifactAdminAccessRole-${aws_codeartifact_domain.repo_domain.domain}"
  description        = "Role providing administrative access to CodeArtifact domain ${aws_codeartifact_domain.repo_domain.domain}"
  assume_role_policy = data.aws_iam_policy_document.assume_admin_role_document.json
  tags               = var.tags
}

# IAM policy attaching admin permissions to the admin access role. Not created if no admin principals are provided.
resource "aws_iam_role_policy" "admin_access_role_policy" {
  count  = var.admin_principals != null && length(var.admin_principals) > 0 ? 1 : 0
  policy = data.aws_iam_policy_document.admin_policy_document[0].json
  role   = aws_iam_role.admin_access_role[0].name
}

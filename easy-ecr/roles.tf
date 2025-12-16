# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0



###################################################################################
#
# Roles allowing read-only (pull) access to repository.
#
###################################################################################

# IAM policy defining read-only access to repository
data "aws_iam_policy_document" "pull_only_policy_document" {
  count = length(var.pull_only_principals) > 0 ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchImportUpstreamImage"
    ]
    resources = ["arn:aws:ecr:${data.aws_region.current_region.region}:${data.aws_caller_identity.current.account_id}:repository/*"]
  }
}

# policy to allow assuming read-only role
data "aws_iam_policy_document" "assume_pull_role_document" {
  count = length(var.pull_only_principals) > 0 ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.pull_only_principals
    }
    actions = ["sts:AssumeRole"]
  }
}

# Role which allows read-only access to repository
resource "aws_iam_role" "repo_read_only_role" {
  count              = length(var.pull_only_principals) > 0 ? 1 : 0
  name               = "ECRPullAccess-${var.repository_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_pull_role_document[0].json
  tags               = var.tags
}

# IAM policy for role allowing read-only (pull) access to repository
resource "aws_iam_role_policy" "read_only_role_policy" {
  count  = length(var.pull_only_principals) > 0 ? 1 : 0
  policy = data.aws_iam_policy_document.pull_only_policy_document[0].json
  role   = aws_iam_role.repo_read_only_role[0].name
}

###################################################################################
#
# Roles allowing read/write (push/pull) access to repository.
#
###################################################################################

data "aws_iam_policy_document" "push_policy_document" {
  count = length(var.push_principals) > 0 ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
      "ecr:BatchImportUpstreamImage"
    ]
    resources = ["arn:aws:ecr:${data.aws_region.current_region.region}:${data.aws_caller_identity.current.account_id}:repository/*"]
  }
}

data "aws_iam_policy_document" "assume_push_role_document" {
  count = length(var.push_principals) > 0 ? 1 : 0
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = var.push_principals
    }
    actions = ["sts:AssumeRole"]
  }
}

# Role which allows read/write access to repository
resource "aws_iam_role" "repo_push_role" {
  count              = length(var.push_principals) > 0 ? 1 : 0
  name               = "ECRPushAccess-${var.repository_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_push_role_document[0].json
  tags               = var.tags
}

# IAM policy for role allowing read/write (push) access to repository
resource "aws_iam_role_policy" "push_role_policy" {
  count  = length(var.push_principals) > 0 ? 1 : 0
  policy = data.aws_iam_policy_document.push_policy_document[0].json
  role   = aws_iam_role.repo_push_role[0].name
}


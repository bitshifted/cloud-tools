# Copyright 2025 Bitshift
# SPDX-License-Identifier: MPL-2.0



locals {
  default_cache_rules = {
    aws_public = merge(var.aws_public_pullthrough_cache_rule, {
      upstream_registry_url = "public.ecr.aws"
    })
    k8s_public = merge(var.k8s_pullthrough_cache_rule, {
      upstream_registry_url = "registry.k8s.io"
    })
    quay = merge(var.quay_pullthrough_cache_rule, {
      upstream_registry_url = "quay.io"
    })
    docker_hub = merge(var.docker_hub_pullthrough_cache_rule, {
      upstream_registry_url = "registry-1.docker.io"
    })
    github = merge(var.github_cr_pullthrough_cache_rule, {
      upstream_registry_url = "ghcr.io"
    })
    gitlab = merge(var.gitlab_cr_pullthrough_cache_rule, {
      upstream_registry_url = "registry.gitlab.com"
    })
  }

}

# Defines default pullthrough cache rules from well-known sources (Docker Hub, Github, Quay etc). By default, all
# cache rules are disabled.
resource "aws_ecr_pull_through_cache_rule" "default_pullthrough_cache_rule" {
  for_each                   = { for k, v in local.default_cache_rules : k => v if v.enabled == true }
  region                     = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  ecr_repository_prefix      = each.value.ecr_repository_prefix
  credential_arn             = can(each.value.credential_arn) ? each.value.credential_arn : null
  custom_role_arn            = can(each.value.custom_role_arn) ? each.value.custom_role_arn : null
  upstream_registry_url      = each.value.upstream_registry_url
  upstream_repository_prefix = each.value.upstream_repository_prefix
}

# Custom user-defined pullthrough cache rules.
resource "aws_ecr_pull_through_cache_rule" "custom_pullthrough_cache_rule" {
  for_each                   = { for k, v in var.pullthrough_cache_rules : k => v }
  region                     = var.ecr_region != null ? var.ecr_region : data.aws_region.current_region.region
  ecr_repository_prefix      = each.value.ecr_repository_prefix
  credential_arn             = can(each.value.credential_arn) ? each.value.credential_arn : null
  custom_role_arn            = can(each.value.custom_role_arn) ? each.value.custom_role_arn : null
  upstream_registry_url      = each.value.upstream_registry_url
  upstream_repository_prefix = each.value.upstream_repository_prefix
}
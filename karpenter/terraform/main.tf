provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = var.cluster_name
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.0"

  cluster_name = var.cluster_name

  enable_v1_permissions             = true
  create_pod_identity_association     = false
  create_instance_profile             = true
  create_iam_role                     = true
  enable_irsa                         = true
  iam_role_use_name_prefix            = true
  iam_role_name                       = "karpenter-controller-${var.cluster_name}"
  node_iam_role_use_name_prefix       = true
  node_iam_role_name                  = "karpenter-node-${var.cluster_name}"

  tags = var.tags
}

resource "aws_ec2_tag" "karpenter_discovery_web" {
  for_each = toset(var.web_subnet_ids)

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

resource "aws_ec2_tag" "karpenter_discovery_app" {
  for_each = toset(var.app_subnet_ids)

  resource_id = each.value
  key         = "karpenter.sh/discovery"
  value       = var.cluster_name
}

resource "aws_ec2_tag" "karpenter_tier_web" {
  for_each = toset(var.web_subnet_ids)

  resource_id = each.value
  key         = "karpenter.sh/tier"
  value       = "web"
}

resource "aws_ec2_tag" "karpenter_tier_app" {
  for_each = toset(var.app_subnet_ids)

  resource_id = each.value
  key         = "karpenter.sh/tier"
  value       = "app"
}

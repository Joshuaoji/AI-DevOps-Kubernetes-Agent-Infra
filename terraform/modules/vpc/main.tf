data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnet_cidrs = concat(var.appgateway_subnet_cidrs, var.web_subnet_cidrs)
  public_subnet_names = concat(
    [for i, _ in var.appgateway_subnet_cidrs : "${var.name}-appgateway-${local.azs[i]}"],
    [for i, _ in var.web_subnet_cidrs : "${var.name}-web-${local.azs[i]}"]
  )
  app_subnet_names = [for i, _ in var.app_subnet_cidrs : "${var.name}-app-${local.azs[i]}"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.name
  cidr = var.vpc_cidr

  azs              = local.azs
  public_subnets   = local.public_subnet_cidrs
  private_subnets  = var.app_subnet_cidrs
  database_subnets = var.database_subnet_cidrs
  intra_subnets    = var.bastion_subnet_cidrs

  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_names   = local.public_subnet_names
  private_subnet_names  = local.app_subnet_names
  database_subnet_names = [for i, _ in var.database_subnet_cidrs : "${var.name}-db-${local.azs[i]}"]
  intra_subnet_names    = [for i, _ in var.bastion_subnet_cidrs : "${var.name}-bastion-${local.azs[i]}"]

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
    Tier                     = "edge"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
    Tier                              = "app"
  }

  database_subnet_tags = {
    Tier = "database"
  }

  intra_subnet_tags = {
    Tier = "bastion"
  }

  tags = var.tags
}

module "vpc" {
  source = "../../modules/vpc"

  name                  = local.name_prefix
  vpc_cidr              = var.vpc_cidr
  availability_zones    = var.availability_zones
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  single_nat_gateway    = var.single_nat_gateway

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name        = "${local.name_prefix}-eks"
  cluster_version     = var.cluster_version
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size

  tags = local.common_tags
}

module "s3" {
  source = "../../modules/s3"

  name           = local.name_prefix
  force_destroy  = var.environment == "dev"
  tags           = local.common_tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_names = var.ecr_repository_names
  tags             = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  name                       = "${local.name_prefix}-postgres"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.database_subnet_ids
  allowed_security_group_ids = [module.eks.node_security_group_id]
  multi_az                   = var.environment != "dev"
  deletion_protection        = var.environment != "dev"

  tags = local.common_tags
}

module "elasticache" {
  source = "../../modules/elasticache"

  name                       = "${local.name_prefix}-redis"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.database_subnet_ids
  allowed_security_group_ids = [module.eks.node_security_group_id]

  tags = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  name              = "${local.name_prefix}-alb"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  certificate_arn   = var.acm_certificate_arn
  target_port       = var.app_target_port
  health_check_path = var.health_check_path
  logs_bucket_name  = module.s3.logs_bucket_name

  tags = local.common_tags
}

resource "aws_security_group_rule" "eks_nodes_from_alb" {
  description              = "Allow ALB traffic to application pods on worker nodes."
  type                     = "ingress"
  from_port                = var.app_target_port
  to_port                  = var.app_target_port
  protocol                 = "tcp"
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = module.alb.security_group_id
}

data "aws_route53_zone" "selected" {
  count = var.domain_name != null ? 1 : 0

  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "app" {
  count = var.domain_name != null ? 1 : 0

  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_iam_policy" "app_data_access" {
  name_prefix = "${local.name_prefix}-app-data-"
  description = "Allow EKS workloads to read and write application artifacts."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ArtifactsBucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.s3.artifacts_bucket_arn,
          "${module.s3.artifacts_bucket_arn}/*"
        ]
      },
      {
        Sid    = "ReadDatabaseCredentials"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = module.rds.credentials_secret_arn
      }
    ]
  })

  tags = local.common_tags
}

module "app_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name_prefix = "${local.name_prefix}-app-"

  role_policy_arns = {
    app_data = aws_iam_policy.app_data_access.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["default:agent-api", "default:agent-worker"]
    }
  }

  tags = local.common_tags
}

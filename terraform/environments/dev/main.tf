module "vpc" {
  source = "../../modules/vpc"

  name                    = local.name_prefix
  vpc_cidr                = var.vpc_cidr
  availability_zones      = var.availability_zones
  appgateway_subnet_cidrs = var.appgateway_subnet_cidrs
  web_subnet_cidrs        = var.web_subnet_cidrs
  app_subnet_cidrs        = var.app_subnet_cidrs
  database_subnet_cidrs   = var.database_subnet_cidrs
  bastion_subnet_cidrs    = var.bastion_subnet_cidrs
  single_nat_gateway      = var.single_nat_gateway

  tags = local.common_tags
}

module "kms" {
  source = "../../modules/kms"

  name = local.name_prefix
  tags = local.common_tags
}

module "bastion" {
  source = "../../modules/bastion"

  name       = local.name_prefix
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.bastion_subnet_ids

  tags = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name       = "${local.name_prefix}-eks"
  cluster_version    = var.cluster_version
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = concat(module.vpc.web_subnet_ids, module.vpc.app_subnet_ids)
  web_subnet_ids     = module.vpc.web_subnet_ids
  app_subnet_ids     = module.vpc.app_subnet_ids
  web_instance_types = var.web_instance_types
  app_instance_types = var.app_instance_types
  web_desired_size   = var.web_desired_size
  web_min_size       = var.web_min_size
  web_max_size       = var.web_max_size
  app_desired_size   = var.app_desired_size
  app_min_size       = var.app_min_size
  app_max_size       = var.app_max_size

  tags = local.common_tags
}

module "s3" {
  source = "../../modules/s3"

  name          = local.name_prefix
  force_destroy = var.environment == "dev"
  tags          = local.common_tags
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
  create_read_replica        = var.create_read_replica
  multi_az                   = false
  deletion_protection        = var.environment != "dev"
  kms_key_arn                = module.kms.key_arn

  tags = local.common_tags
}

module "public_alb" {
  source = "../../modules/alb"

  name              = "${local.name_prefix}-public"
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.appgateway_subnet_ids
  internal          = false
  certificate_arn   = var.acm_certificate_arn
  target_port       = var.web_target_port
  health_check_path = var.web_health_check_path
  logs_bucket_name  = module.s3.logs_bucket_name

  tags = merge(local.common_tags, {
    Tier = "app-gateway"
  })
}

module "waf" {
  source = "../../modules/waf"

  name    = "${local.name_prefix}-public"
  alb_arn = module.public_alb.alb_arn
  tags    = local.common_tags
}

module "internal_alb" {
  source = "../../modules/alb"

  name                               = "${local.name_prefix}-internal"
  vpc_id                             = module.vpc.vpc_id
  subnet_ids                         = module.vpc.app_subnet_ids
  internal                           = true
  target_port                        = var.app_target_port
  health_check_path                  = var.app_health_check_path
  allowed_ingress_security_group_ids = [module.eks.node_security_group_id]

  tags = merge(local.common_tags, {
    Tier = "internal-lb"
  })
}

module "private_dns" {
  source = "../../modules/private-dns"

  name   = var.private_dns_zone_name
  vpc_id = module.vpc.vpc_id

  records = [
    {
      name = "api.${var.private_dns_zone_name}"
      type = "A"
      alias = {
        name                   = module.internal_alb.alb_dns_name
        zone_id                = module.internal_alb.alb_zone_id
        evaluate_target_health = true
      }
    }
  ]

  tags = local.common_tags
}

resource "aws_security_group_rule" "web_nodes_from_public_alb" {
  description              = "Allow public ALB traffic to web tier pods."
  type                     = "ingress"
  from_port                = var.web_target_port
  to_port                  = var.web_target_port
  protocol                 = "tcp"
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = module.public_alb.security_group_id
}

resource "aws_security_group_rule" "web_nodes_to_internal_alb" {
  description              = "Allow web tier pods to reach the internal ALB."
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.internal_alb.security_group_id
  source_security_group_id = module.eks.node_security_group_id
}

resource "aws_security_group_rule" "app_nodes_from_internal_alb" {
  description              = "Allow internal ALB traffic to application tier pods."
  type                     = "ingress"
  from_port                = var.app_target_port
  to_port                  = var.app_target_port
  protocol                 = "tcp"
  security_group_id        = module.eks.node_security_group_id
  source_security_group_id = module.internal_alb.security_group_id
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
    name                   = module.public_alb.alb_dns_name
    zone_id                = module.public_alb.alb_zone_id
    evaluate_target_health = true
  }
}

resource "aws_iam_policy" "app_data_access" {
  name_prefix = "${local.name_prefix}-app-data-"
  description = "Allow application tier workloads to access data services."

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
      },
      {
        Sid    = "DecryptSecrets"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = module.kms.key_arn
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
      namespace_service_accounts = ["web:web-app", "app:app-api"]
    }
  }

  tags = local.common_tags
}

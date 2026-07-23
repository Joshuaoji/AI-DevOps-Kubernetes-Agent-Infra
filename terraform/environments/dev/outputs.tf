output "vpc_id" {
  description = "ID of the VPC."
  value       = module.vpc.vpc_id
}

output "eks_cluster_name" {
  description = "Name of the EKS cluster."
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint for the EKS API server."
  value       = module.eks.cluster_endpoint
}

output "configure_kubectl" {
  description = "Command to configure kubectl for the EKS cluster."
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "public_alb_dns_name" {
  description = "Public DNS name of the internet-facing application load balancer."
  value       = module.public_alb.alb_dns_name
}

output "internal_alb_dns_name" {
  description = "DNS name of the internal application load balancer."
  value       = module.internal_alb.alb_dns_name
}

output "internal_api_fqdn" {
  description = "Private DNS FQDN for the application API."
  value       = "api.${var.private_dns_zone_name}"
}

output "public_alb_target_group_arn" {
  description = "Target group ARN for web tier pods."
  value       = module.public_alb.target_group_arn
}

output "internal_alb_target_group_arn" {
  description = "Target group ARN for application tier pods."
  value       = module.internal_alb.target_group_arn
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL protecting the public ALB."
  value       = module.waf.web_acl_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for container images."
  value       = module.ecr.repository_urls
}

output "rds_primary_endpoint" {
  description = "PostgreSQL primary endpoint."
  value       = module.rds.primary_endpoint
  sensitive   = true
}

output "rds_replica_endpoint" {
  description = "PostgreSQL read replica endpoint."
  value       = module.rds.replica_endpoint
  sensitive   = true
}

output "rds_credentials_secret_arn" {
  description = "Secrets Manager ARN for database credentials."
  value       = module.rds.credentials_secret_arn
}

output "kms_key_arn" {
  description = "KMS key ARN used for secrets encryption."
  value       = module.kms.key_arn
}

output "artifacts_bucket_name" {
  description = "S3 bucket for application artifacts."
  value       = module.s3.artifacts_bucket_name
}

output "bastion_instance_id" {
  description = "Session Manager bastion instance ID."
  value       = module.bastion.bastion_instance_id
}

output "app_service_account_role_arn" {
  description = "IAM role ARN for application pods via IRSA."
  value       = module.app_irsa.iam_role_arn
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller."
  value       = module.eks.aws_load_balancer_controller_role_arn
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for the cluster autoscaler."
  value       = module.eks.cluster_autoscaler_role_arn
}

output "application_url" {
  description = "Public application URL."
  value       = var.domain_name != null ? "https://${var.domain_name}" : "http://${module.public_alb.alb_dns_name}"
}

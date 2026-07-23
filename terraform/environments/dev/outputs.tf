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

output "alb_dns_name" {
  description = "Public DNS name of the application load balancer."
  value       = module.alb.alb_dns_name
}

output "alb_target_group_arn" {
  description = "Target group ARN for registering application pods."
  value       = module.alb.target_group_arn
}

output "ecr_repository_urls" {
  description = "ECR repository URLs for container images."
  value       = module.ecr.repository_urls
}

output "rds_endpoint" {
  description = "PostgreSQL endpoint."
  value       = module.rds.endpoint
  sensitive   = true
}

output "rds_credentials_secret_arn" {
  description = "Secrets Manager ARN for database credentials."
  value       = module.rds.credentials_secret_arn
}

output "redis_primary_endpoint" {
  description = "Redis primary endpoint."
  value       = module.elasticache.primary_endpoint
  sensitive   = true
}

output "artifacts_bucket_name" {
  description = "S3 bucket for application artifacts."
  value       = module.s3.artifacts_bucket_name
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
  description = "Application URL when a Route 53 record is configured."
  value       = var.domain_name != null ? "https://${var.domain_name}" : "http://${module.alb.alb_dns_name}"
}

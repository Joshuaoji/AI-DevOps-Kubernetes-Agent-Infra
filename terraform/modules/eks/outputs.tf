output "cluster_name" {
  description = "EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster."
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS control plane."
  value       = module.eks.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ID attached to EKS worker nodes."
  value       = module.eks.node_security_group_id
}

output "additional_node_security_group_id" {
  description = "Additional security group attached to worker nodes."
  value       = aws_security_group.node.id
}

output "oidc_provider_arn" {
  description = "ARN of the OIDC provider for IRSA."
  value       = module.eks.oidc_provider_arn
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for the cluster autoscaler."
  value       = try(module.cluster_autoscaler_irsa[0].iam_role_arn, null)
}

output "aws_load_balancer_controller_role_arn" {
  description = "IAM role ARN for the AWS Load Balancer Controller."
  value       = try(module.aws_load_balancer_controller_irsa[0].iam_role_arn, null)
}

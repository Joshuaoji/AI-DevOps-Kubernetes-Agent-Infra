output "cluster_name" {
  description = "EKS cluster name."
  value       = var.cluster_name
}

output "karpenter_controller_role_arn" {
  description = "IAM role ARN for the Karpenter controller service account."
  value       = module.karpenter.iam_role_arn
}

output "karpenter_node_role_arn" {
  description = "IAM role ARN assumed by Karpenter-provisioned nodes."
  value       = module.karpenter.node_iam_role_arn
}

output "karpenter_node_role_name" {
  description = "IAM role name for EC2NodeClass spec.role."
  value       = module.karpenter.node_iam_role_name
}

output "karpenter_interruption_queue_name" {
  description = "SQS queue name for Karpenter spot interruption handling."
  value       = module.karpenter.queue_name
}

output "karpenter_interruption_queue_arn" {
  description = "SQS queue ARN for Karpenter spot interruption handling."
  value       = module.karpenter.queue_arn
}

output "karpenter_instance_profile_name" {
  description = "Instance profile name created for Karpenter nodes."
  value       = module.karpenter.instance_profile_name
}

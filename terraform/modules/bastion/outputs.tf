output "bastion_instance_id" {
  description = "Instance ID of the Session Manager bastion host."
  value       = aws_instance.bastion.id
}

output "bastion_security_group_id" {
  description = "Security group ID for the bastion host."
  value       = aws_security_group.bastion.id
}

output "ssm_endpoint_security_group_id" {
  description = "Security group ID for SSM VPC endpoints."
  value       = aws_security_group.endpoints.id
}

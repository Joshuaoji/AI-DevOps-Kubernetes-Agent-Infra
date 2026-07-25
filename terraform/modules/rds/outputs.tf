output "primary_endpoint" {
  description = "Primary RDS instance endpoint."
  value       = aws_db_instance.primary.address
}

output "replica_endpoint" {
  description = "Read replica endpoint."
  value       = try(aws_db_instance.replica[0].address, null)
}

output "endpoint" {
  description = "Primary RDS instance endpoint."
  value       = aws_db_instance.primary.address
}

output "port" {
  description = "RDS instance port."
  value       = aws_db_instance.primary.port
}

output "database_name" {
  description = "Default database name."
  value       = aws_db_instance.primary.db_name
}

output "security_group_id" {
  description = "Security group ID for the RDS instances."
  value       = aws_security_group.this.id
}

output "credentials_secret_arn" {
  description = "Secrets Manager ARN containing database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

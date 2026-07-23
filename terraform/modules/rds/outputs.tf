output "endpoint" {
  description = "RDS instance endpoint."
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS instance port."
  value       = aws_db_instance.this.port
}

output "database_name" {
  description = "Default database name."
  value       = aws_db_instance.this.db_name
}

output "security_group_id" {
  description = "Security group ID for the RDS instance."
  value       = aws_security_group.this.id
}

output "credentials_secret_arn" {
  description = "Secrets Manager ARN containing database credentials."
  value       = aws_secretsmanager_secret.db_credentials.arn
}

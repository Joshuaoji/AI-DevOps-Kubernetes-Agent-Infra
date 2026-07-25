variable "name" {
  description = "Name prefix for RDS resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the database security group."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the RDS subnet group."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to the database."
  type        = list(string)
}

variable "engine" {
  description = "Database engine."
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "Database engine version."
  type        = string
  default     = "16.4"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t3.medium"
}

variable "allocated_storage" {
  description = "Allocated storage in GB."
  type        = number
  default     = 20
}

variable "database_name" {
  description = "Name of the default database."
  type        = string
  default     = "appdb"
}

variable "master_username" {
  description = "Master database username."
  type        = string
  default     = "dbadmin"
}

variable "multi_az" {
  description = "Enable Multi-AZ deployment on the primary instance."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = false
}

variable "create_read_replica" {
  description = "Create a cross-AZ read replica."
  type        = bool
  default     = true
}

variable "replica_instance_class" {
  description = "Instance class for the read replica."
  type        = string
  default     = null
}

variable "kms_key_arn" {
  description = "KMS key ARN for encrypting secrets."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to RDS resources."
  type        = map(string)
  default     = {}
}

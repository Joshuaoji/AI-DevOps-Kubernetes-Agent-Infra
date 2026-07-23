variable "name" {
  description = "Name prefix for ElastiCache resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the cache security group."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the ElastiCache subnet group."
  type        = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups allowed to connect to Redis."
  type        = list(string)
}

variable "node_type" {
  description = "ElastiCache node type."
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_clusters" {
  description = "Number of cache clusters in the replication group."
  type        = number
  default     = 2
}

variable "engine_version" {
  description = "Redis engine version."
  type        = string
  default     = "7.1"
}

variable "tags" {
  description = "Tags applied to ElastiCache resources."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name prefix for the load balancer."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for the load balancer."
  type        = string
}

variable "subnet_ids" {
  description = "Public subnet IDs for the load balancer."
  type        = list(string)
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listeners. Leave null to create HTTP only."
  type        = string
  default     = null
}

variable "target_port" {
  description = "Port exposed by application pods behind the load balancer."
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "Health check path for target groups."
  type        = string
  default     = "/healthz"
}

variable "logs_bucket_name" {
  description = "S3 bucket name for ALB access logs."
  type        = string
  default     = null
}

variable "allowed_ingress_cidr_blocks" {
  description = "CIDR blocks allowed to reach the load balancer."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "Tags applied to load balancer resources."
  type        = map(string)
  default     = {}
}

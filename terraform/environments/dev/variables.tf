variable "aws_region" {
  description = "AWS region to deploy infrastructure into."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used as a prefix for resources."
  type        = string
  default     = "ai-devops-agent"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to use. Leave empty to auto-select the first two in the region."
  type        = list(string)
  default     = []
}

variable "appgateway_subnet_cidrs" {
  description = "CIDR blocks for App Gateway / internet-facing ALB subnets."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "web_subnet_cidrs" {
  description = "CIDR blocks for the public web tier subnets."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for the private application tier subnets."
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for the database tier subnets."
  type        = list(string)
  default     = ["10.0.30.0/24", "10.0.31.0/24"]
}

variable "bastion_subnet_cidrs" {
  description = "CIDR blocks for the bastion / management subnet."
  type        = list(string)
  default     = ["10.0.40.0/24"]
}

variable "private_dns_zone_name" {
  description = "Private hosted zone name for internal service discovery."
  type        = string
  default     = "internal.local"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.31"
}

variable "web_instance_types" {
  description = "EC2 instance types for the web tier node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "app_instance_types" {
  description = "EC2 instance types for the application tier node group."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "web_desired_size" {
  description = "Desired number of web tier nodes."
  type        = number
  default     = 2
}

variable "web_min_size" {
  description = "Minimum number of web tier nodes."
  type        = number
  default     = 1
}

variable "web_max_size" {
  description = "Maximum number of web tier nodes."
  type        = number
  default     = 4
}

variable "app_desired_size" {
  description = "Desired number of application tier nodes."
  type        = number
  default     = 2
}

variable "app_min_size" {
  description = "Minimum number of application tier nodes."
  type        = number
  default     = 1
}

variable "app_max_size" {
  description = "Maximum number of application tier nodes."
  type        = number
  default     = 4
}

variable "domain_name" {
  description = "Optional Route 53 hosted zone domain for the public application."
  type        = string
  default     = null
}

variable "acm_certificate_arn" {
  description = "Optional ACM certificate ARN for HTTPS on the public ALB."
  type        = string
  default     = null
}

variable "ecr_repository_names" {
  description = "ECR repositories to create for container images."
  type        = list(string)
  default     = ["web-app", "app-api"]
}

variable "web_target_port" {
  description = "Port exposed by web tier pods."
  type        = number
  default     = 80
}

variable "app_target_port" {
  description = "Port exposed by application tier pods."
  type        = number
  default     = 8080
}

variable "web_health_check_path" {
  description = "Health check path for the web tier target group."
  type        = string
  default     = "/"
}

variable "app_health_check_path" {
  description = "Health check path for the application tier target group."
  type        = string
  default     = "/healthz"
}

variable "single_nat_gateway" {
  description = "Use one NAT gateway instead of one per AZ."
  type        = bool
  default     = true
}

variable "create_read_replica" {
  description = "Create a PostgreSQL read replica in the second AZ."
  type        = bool
  default     = true
}

variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones to spread subnets across."
  type        = list(string)
  default     = []
}

variable "appgateway_subnet_cidrs" {
  description = "CIDR blocks for App Gateway / internet-facing ALB subnets."
  type        = list(string)
}

variable "web_subnet_cidrs" {
  description = "CIDR blocks for the public web tier subnets."
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for the private application tier subnets."
  type        = list(string)
}

variable "database_subnet_cidrs" {
  description = "CIDR blocks for the database tier subnets."
  type        = list(string)
}

variable "bastion_subnet_cidrs" {
  description = "CIDR blocks for the bastion / management subnet."
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Whether to create NAT gateways for private subnet egress."
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT gateway instead of one per AZ."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all VPC resources."
  type        = map(string)
  default     = {}
}

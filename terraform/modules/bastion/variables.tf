variable "name" {
  description = "Name prefix for bastion resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for SSM interface endpoints and optional bastion host."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to bastion resources."
  type        = map(string)
  default     = {}
}

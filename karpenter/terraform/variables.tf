variable "aws_region" {
  description = "AWS region of the EKS cluster."
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the existing EKS cluster."
  type        = string
}

variable "web_subnet_ids" {
  description = "Web tier subnet IDs (from main stack module.vpc.web_subnet_ids)."
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "App tier subnet IDs (from main stack module.vpc.app_subnet_ids)."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to Karpenter AWS resources."
  type        = map(string)
  default     = {
    ManagedBy = "terraform"
    Component = "karpenter"
  }
}

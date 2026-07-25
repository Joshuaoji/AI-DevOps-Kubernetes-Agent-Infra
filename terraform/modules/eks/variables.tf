variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.31"
}

variable "vpc_id" {
  description = "VPC ID where the cluster will be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for the EKS control plane."
  type        = list(string)
}

variable "web_subnet_ids" {
  description = "Subnet IDs for the web tier managed node group."
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "Subnet IDs for the application tier managed node group."
  type        = list(string)
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

variable "enable_cluster_autoscaler" {
  description = "Attach IAM policy for the cluster autoscaler."
  type        = bool
  default     = true
}

variable "enable_aws_load_balancer_controller" {
  description = "Create IRSA role for the AWS Load Balancer Controller."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to EKS resources."
  type        = map(string)
  default     = {}
}

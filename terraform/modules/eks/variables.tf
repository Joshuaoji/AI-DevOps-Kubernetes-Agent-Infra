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
  description = "Subnet IDs for the EKS control plane and node groups."
  type        = list(string)
}

variable "node_instance_types" {
  description = "EC2 instance types for managed node groups."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
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

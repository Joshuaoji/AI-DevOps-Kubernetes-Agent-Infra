variable "repository_names" {
  description = "List of ECR repository names to create."
  type        = list(string)
}

variable "scan_on_push" {
  description = "Enable image scanning on push."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to ECR repositories."
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "Name prefix for S3 buckets."
  type        = string
}

variable "create_artifacts_bucket" {
  description = "Create an S3 bucket for application artifacts and models."
  type        = bool
  default     = true
}

variable "create_logs_bucket" {
  description = "Create an S3 bucket for ALB and application logs."
  type        = bool
  default     = true
}

variable "force_destroy" {
  description = "Allow bucket deletion even when objects exist."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to S3 buckets."
  type        = map(string)
  default     = {}
}

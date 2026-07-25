variable "name" {
  description = "Name prefix for WAF resources."
  type        = string
}

variable "alb_arn" {
  description = "ARN of the ALB to associate with the WAF Web ACL."
  type        = string
}

variable "tags" {
  description = "Tags applied to WAF resources."
  type        = map(string)
  default     = {}
}

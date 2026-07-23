variable "name" {
  description = "Name of the private hosted zone."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to associate with the private hosted zone."
  type        = string
}

variable "records" {
  description = "Private DNS records to create in the hosted zone."
  type = list(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string))
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = optional(bool, true)
    }))
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to Route 53 resources."
  type        = map(string)
  default     = {}
}

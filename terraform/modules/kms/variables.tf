variable "name" {
  description = "Name prefix for KMS resources."
  type        = string
}

variable "tags" {
  description = "Tags applied to KMS resources."
  type        = map(string)
  default     = {}
}

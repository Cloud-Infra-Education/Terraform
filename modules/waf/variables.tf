variable "our_team" {
  type        = string
  description = "Prefix for naming WAF resources"
}

variable "domain_name" {
  type        = string
  description = "Used for naming WAF resources"
}

variable "tags" {
  type        = map(string)
  description = "Optional tags to apply to WAF resources"
  default     = {}
}


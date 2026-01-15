variable "domain_cf_state_path" {
  type        = string
  default     = "../07-domain-cf/terraform.tfstate"
}

variable "ga_name" {
  type    = string
  default = "formation-lap-ga"
}

variable "alb_lookup_tag_value" {
  type    = string
  default = "formation-lap/msa-ingress"
}

variable "domain_name" {
  type = string
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID (optional, if not provided will try to lookup by domain name)"
  default     = ""
}

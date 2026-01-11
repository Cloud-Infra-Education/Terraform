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

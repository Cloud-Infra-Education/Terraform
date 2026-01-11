variable "infra_state_path" {
  description = "local backend 기준 01-infra의 terraform.tfstate 경로"
  type        = string
  default     = "../01-infra/terraform.tfstate"
}

variable "our_team" {
  type    = string
  default = "formation-lap"
}

variable "domain_name" {
  type = string
}

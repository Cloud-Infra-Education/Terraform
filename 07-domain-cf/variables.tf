variable "infra_state_path" {
  type    = string
  default = "../01-infra/terraform.tfstate"
}

variable "kubernetes_state_path" {
  type    = string
  default = "../02-kubernetes/terraform.tfstate"
}

variable "certificate_state_path" {
  type    = string
  default = "../06-certificate/terraform.tfstate"
}

variable "our_team" {
  type    = string
  default = "formation-lap"
}

variable "domain_name" {
  type = string
}

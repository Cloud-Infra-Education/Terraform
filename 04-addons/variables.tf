variable "infra_state_path" {
  description = "local backend 기준 01-infra의 terraform.tfstate 경로"
  type        = string
  default     = "../01-infra/terraform.tfstate"
}

variable "kubernetes_state_path" {
  description = "local backend 기준 02-kubernetes의 terraform.tfstate 경로"
  type        = string
  default     = "../02-kubernetes/terraform.tfstate"
}

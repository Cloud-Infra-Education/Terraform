variable "kubernetes_state_path" {
  description = "02-kubernetes의 terraform.tfstate 경로"
  type        = string
  default     = "../02-kubernetes/terraform.tfstate"
}

variable "namespace" {
  type    = string
  default = "app-monitoring-seoul"
}

variable "amp_workspace_alias_seoul" {
  type    = string
  default = null
}

variable "eks_seoul_oidc_provider_arn" {
  type    = string
  default = null
}

variable "grafana_admin_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "namespace" {
  type = string
  default = "monitoring"
}

# ====== EKS 모듈에서 Output으로 받아옴 ======
variable "eks_seoul_cluster_name" {
  type = string
}
variable "eks_seoul_oidc_provider_arn" {
  type = string
}
variable "eks_oregon_cluster_name" {
  type = string
}
variable "eks_oregon_oidc_provider_arn" {
  type = string
}
variable "amp_workspace_alias_seoul" {
  type    = string
  default = "demo-amp-seoul"
}
variable "amp_workspace_alias_oregon" {
  type    = string
  default = "demo-amp-oregon"
}
variable "grafana_admin_password" {
  type      = string
  sensitive = true
}


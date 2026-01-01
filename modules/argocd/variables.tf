variable "argocd_namespace" {
  type = string
}

variable "argocd_chart_version" {
  type = string
}

#--------애플리케이션 파트--------
variable "argocd_app_name" {
  type = string
}

variable "argocd_app_repo_url" {
  type = string
}

variable "argocd_app_path" {
  type = string
}

variable "argocd_app_target_revision" {
  type = string
}

variable "argocd_app_destination_namespace" {
  type = string
}
variable "argocd_app_enabled" {
  type    = bool
  default = false
}

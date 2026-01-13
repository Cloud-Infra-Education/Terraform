variable "kubernetes_state_path" {
  description = "local backend 기준 02-kubernetes의 terraform.tfstate 경로"
  type        = string
  default     = "../02-kubernetes/terraform.tfstate"
}

variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_chart_version" {
  type    = string
  default = ""
}

variable "argocd_app_name" {
  type    = string
  default = "manifest-management-test"
}

variable "argocd_app_repo_url" {
  description = "깃허브 Manifest 레포 URL"
  type        = string
  default     = "https://github.com/Cloud-Infra-Education/Manifests.git"
}

variable "argocd_app_path" {
  type    = string
  default = "base"
}

variable "argocd_app_target_revision" {
  type    = string
  default = "feat/#1"  # 현재 Manifests 저장소의 기본 브랜치
}

variable "argocd_app_destination_namespace" {
  type    = string
  default = "formation-lap"
}

variable "argocd_app_enabled" {
  description = "ArgoCD 설치 후 Application 생성 여부"
  type        = bool
  default     = false
}

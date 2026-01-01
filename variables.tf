variable "key_name_kor" {
  description = "EC2 Key Pair in Seoul Region"
  type        = string
}

variable "key_name_usa" {
  description = "EC2 Key Pair in Oregon Region"
  type        = string
}

variable "admin_cidr" {
  type = string
}

variable "bastion_instance_type" {
  default = "t3.micro"
}

variable "eks_public_access_cidrs" {
  description = "EKS에 접속가능한 CIDR 참조"
  type        = list(string)
}

variable "eks_admin_principal_arn" {
  description = "EKS Access Entry 생성용"
  type        = string
}

variable "ecr_replication_repo_prefixes" {
  description = "ECR 미러링 관련 옵션"
  type        = list(string)
  default = [
    "user-service",
    "order-service",
    "product-service",
  ]
}

# =====================
# argocd 모듈 관련 변수
# =====================
variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "argocd_chart_version" {
  type    = string
  default = ""
}

variable "argocd_app_name" {
  description = "ArgoCD Application name"
  type        = string
  default     = "manifest-management-test"
}

variable "argocd_app_repo_url" { ############ 나중에 수정
  description = "깃허브 Manifest 레포 URL"
  type        = string
  default     = "https://github.com/MaxJagger/formation-lap-eve-manifests.git"
}

variable "argocd_app_path" {
  type    = string
  default = "base"
}

variable "argocd_app_target_revision" {
  type    = string
  default = "main"
}

variable "argocd_app_destination_namespace" {
  type    = string
  default = "formation-lap"
}

variable "argocd_app_enabled" {
  description = "EKS에 ArgoCD 설치까지 마치고 앱을 만들기로..."
  type        = bool
  default     = false
}

# =================
# ga 관련 변수
# =================
variable "ga_name" {
  type    = string
  default = "formation-lap-ga"
}

variable "alb_lookup_tag_value" {
  type    = string
  default = "formation-lap/msa-ingress"
}

variable "ga_enabled" {
  type    = bool
  default = false
}

# =================
# Route53 관련 변수
# =================
variable "domain_name" {
  type        = string
}

variable "api_subdomain" {
  type        = string
  default     = "api"
}



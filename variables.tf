variable "our_team" {
  type    = string
  default = "formation-lap"
}

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

# ======= enabled 스위치 모음=======
variable "argocd_app_enabled" {
  description = "EKS에 ArgoCD 설치까지 마치고 앱을 만들기로..."
  type        = bool
  default     = false
}
variable "ga_set_enabled" {
  type    = bool
  default = false
}
variable "domain_set_enabled" {
  description = "ACM을 만들고 도메인을 구성한다."
  type        = bool
  default     = false
}
variable "db_cluster_enabled" {
  description = "DB 스위치"
  type        = bool
  default     = false
}

# ==========
# ECR 미러링
# ==========
variable "ecr_replication_repo_prefixes" {
  type = list(string)
  default = [
    "user-service",
    "order-service",
    "product-service",
  ]
}

# ===========================
# S3 버킷 이름(전세계 고유값)
# ===========================
variable "origin_bucket_name" {
  type = string
}

# =============
# VPN 설정 변수
# =============
variable "onprem_public_ip" {
  type = string
}

variable "onprem_private_cidr" {
  type = string
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


# =================
# ga 관련 변수
# =================
variable "ga_name" {
  type    = string
  default = "y2om-formation-lap-ga"
}

variable "alb_lookup_tag_value" {
  type    = string
  default = "formation-lap/msa-ingress"
}


# =================
# Route53 관련 변수
# =================
variable "domain_name" {
  type = string
}


# ================
# DB 클러스터 계정
# ================
variable "db_username" {
  description = "DB master username"
  type        = string
}

variable "db_password" {
  description = "DB master password"
  type        = string
  sensitive   = true
}



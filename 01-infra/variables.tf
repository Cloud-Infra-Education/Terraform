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

# =============
# VPN 설정 변수
# =============
variable "onprem_public_ip" {
  type = string
}

variable "onprem_private_cidr" {
  type = string
}

# ===========================
# S3 버킷 이름(전세계 고유값)
# ===========================
variable "origin_bucket_name" {
  type = string
}

# ===========================
# Lambda 함수를 위한 변수들
# ===========================
variable "our_team" {
  type        = string
  description = "팀 이름 (리소스 이름 prefix)"
}

variable "db_username" {
  type        = string
  description = "DB 사용자명 (RDS Proxy를 통해 연결)"
  default     = null
}

variable "db_password" {
  type        = string
  description = "DB 비밀번호 (RDS Proxy를 통해 연결)"
  sensitive   = true
  default     = null
}

variable "db_name" {
  type        = string
  description = "DB 이름"
  default     = "ott_db"
}

# ===========================
# Remote state 경로
# ===========================
variable "kubernetes_state_path" {
  description = "02-kubernetes의 terraform.tfstate 경로"
  type        = string
  default     = "../02-kubernetes/terraform.tfstate"
}

variable "database_state_path" {
  description = "03-database의 terraform.tfstate 경로"
  type        = string
  default     = "../03-database/terraform.tfstate"
}

# ===========================
# ECR Repository URL (fallback용, 보통은 remote state에서 가져옴)
# ===========================
variable "ecr_url_video" {
  type        = string
  description = "Video processor Lambda용 ECR 이미지 URL (remote state가 없을 때 사용)"
  default     = null
}


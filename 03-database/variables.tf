variable "our_team" {
  type    = string
  default = "formation-lap"
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

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "ott_db"
}

# ============================================
# remote_state 경로 (local backend 기준)
# ============================================
variable "infra_state_path" {
  description = "01-infra의 terraform.tfstate 경로"
  type        = string
  default     = "../01-infra/terraform.tfstate"
}

variable "kubernetes_state_path" {
  description = "02-kubernetes의 terraform.tfstate 경로"
  type        = string
  default     = "../02-kubernetes/terraform.tfstate"
}

# ============================================
# Lambda API 연동 설정
# ============================================
variable "catalog_api_base" {
  description = "FastAPI 도메인 (예: https://api.matchacake.click/api)"
  type        = string
  default     = ""
}

variable "internal_token" {
  description = "FastAPI와 공유하는 내부 토큰 (Lambda ↔ FastAPI 인증용)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "tmdb_api_key" {
  description = "TMDB API 키 (영상 정보 가져오기용, 선택사항)"
  type        = string
  sensitive   = true
  default     = ""
}

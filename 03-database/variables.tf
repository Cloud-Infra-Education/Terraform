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

# ============================================================
# Lambda Video Processor 변수
# ============================================================
variable "catalog_api_base" {
  description = "Backend API base URL"
  type        = string
  default     = "https://api.exampleott.click"
}

variable "internal_token" {
  description = "Internal token for API authentication"
  type        = string
  sensitive   = true
  default     = "formation-lap-internal-token-2024-secret-key"
}

variable "cloudfront_domain" {
  description = "CloudFront domain name"
  type        = string
  default     = "www.matchacake.click"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "y2om_db"
}

variable "tmdb_api_key" {
  description = "TMDB API key for movie metadata"
  type        = string
  sensitive   = true
  default     = ""
}

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


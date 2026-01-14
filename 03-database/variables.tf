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

variable "dms_db_username" {
  type        = string
  description = "DMS replication user for Aurora clusters"
}
variable "dms_db_password" {
  type        = string
  description = "Password for DMS replication user"
  sensitive   = true
}

variable "onprem_private_cidr" {
  type        = string
  description = "On-premises private VM IP for DB access"
}

variable "onprem_public_cidr" {
  type        = string
  description = "On-prem public IP (관리용 PC or VPN)"
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


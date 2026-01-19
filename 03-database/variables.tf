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
# Database 모듈 변수
# ============================================
variable "onprem_public_ip" {
  description = "Terraform 실행 머신의 공인 IP (Security Group 규칙용, CIDR 형식: IP/32)"
  type        = string
}

# ============================================
# ConfigMap 변수
# ============================================
variable "domain_name" {
  description = "도메인 이름 (예: matchacake.click, exampleott.click)"
  type        = string
}

variable "keycloak_url" {
  description = "Keycloak URL (선택사항, 비워두면 api.<domain_name>/keycloak로 자동 생성)"
  type        = string
  default     = null
}

variable "cloudfront_domain" {
  description = "CloudFront 도메인 (선택사항, 비워두면 www.<domain_name>로 자동 생성)"
  type        = string
  default     = null
}

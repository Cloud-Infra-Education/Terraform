variable "infra_state_path" {
  description = "local backend 기준 01-infra의 terraform.tfstate 경로"
  type        = string
  default     = "../01-infra/terraform.tfstate"
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
  type = list(string)
  default = [
    "user-service",
    "backend-api",
  ]
}


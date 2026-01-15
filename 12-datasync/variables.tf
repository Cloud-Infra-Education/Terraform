variable "our_team" {
  type    = string
  default = "formation-lab"
}

variable "onprem_private_ip" {
  type = string
}

variable "onprem_mg_private_cidr" {
  type = string
}

variable "datasync_agent_arn" {
  type = string
}

# ============================================
# remote_state 경로 (local backend 기준)
# ============================================
variable "infra_state_path" {
  description = "01-infra의 terraform.tfstate 경로"
  type        = string
  default     = "../01-infra/terraform.tfstate"
}


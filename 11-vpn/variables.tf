variable "infra_state_path" {
  description = "01-infra local backend terraform.tfstate 경로"
  type        = string
  default     = "../01-infra/terraform.tfstate"
}

variable "seoul_vpc_id" {
  description = "서울 VPC ID(직접 지정). 비워두면 remote_state의 kor_vpc_id 사용"
  type        = string
  default     = ""
}

variable "seoul_tgw_route_table_id" {
  description = "서울 TGW Route Table ID(비워두면 TGW association default RT 사용)"
  type        = string
  default     = ""
}

variable "onprem_public_ip" {
  type = string
}

variable "onprem_private_cidr" {
  type    = string
  default = ""
}

variable "onprem_private_cidrs" {
  type    = list(string)
  default = []
}

variable "manage_vpc_routes" {
  description = "서울 VPC 라우팅테이블에 onprem -> TGW 라우트를 Terraform이 추가할지"
  type        = bool
  default     = true
}

variable "vpc_route_table_ids" {
  description = "manage_vpc_routes=true일 때 대상 RT IDs(비우면 VPC의 모든 RT 조회해서 사용)"
  type        = list(string)
  default     = []
}

variable "keyexchange" {
  type    = string
  default = "ikev1"
}

variable "ike" {
  type    = string
  default = "aes128-sha1-modp1024!"
}

variable "esp" {
  type    = string
  default = "aes128-sha1!"
}

variable "dpd_delay" {
  type    = string
  default = "10s"
}

variable "dpd_timeout" {
  type    = string
  default = "30s"
}


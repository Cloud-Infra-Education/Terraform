variable "db_username" {
  description = "DB master username"
  type = string
}
variable "db_password" {
  description = "DB master password"
  type      = string
  sensitive = true
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


variable "kor_vpc_id" {
  type = string
}
variable "usa_vpc_id" {
  type = string
}

variable "kor_private_db_subnet_ids" {
  type = list(string)
}
variable "usa_private_db_subnet_ids" {
  type = list(string)
}

variable "kor_db_endpoint" {
  type = string
}

variable "usa_db_endpoint" {
  type = string
}

variable "seoul_eks_workers_sg_id" {
  type = string
}
variable "oregon_eks_workers_sg_id" {
  type = string
}

variable "our_team" {
  type = string
}

variable "db_port" {
  type        = number
  default     = 3306
}

variable "proxy_require_tls" {
  type        = bool
  default     = false
}

variable "proxy_idle_client_timeout" {
  description = "Seconds"
  type        = number
  default     = 1800
}

variable "proxy_debug_logging" {
  type        = bool
  default     = false
}

variable "proxy_max_connections_percent" {
  type        = number
  default     = 100
}

variable "proxy_max_idle_connections_percent" {
  type        = number
  default     = 50
}

variable "proxy_connection_borrow_timeout" {
  description = "Seconds"
  type        = number
  default     = 120
}

variable "onprem_private_cidr" {
  type        = string
  description = "On-premises private VM IP for DB access"
}

variable "onprem_public_ip" {
  type        = string
  description = "On-prem public IP (관리용 PC or VPN)"
}


variable "dms_security_group_id" {
  type = string
  default = null
}

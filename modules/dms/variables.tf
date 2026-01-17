variable "name_prefix" {
  description = "리소스 네이밍 prefix"
  type        = string
  default     = "onprem-to-aurora"
}

variable "vpc_id" {
  type        = string
}

variable "subnet_ids" {
  type        = list(string)
}

variable "target_db_security_group_id" {
  type        = string
  default     = null
}

variable "replication_instance_class" {
  description = "DMS replication instance class"
  type        = string
  default     = "dms.t3.medium"
}

variable "allocated_storage" {
  type        = number
  default     = 50
}

variable "multi_az" {
  type        = bool
  default     = false
}

variable "publicly_accessible" {
  description = "DMS replication instance publicly accessible"
  type        = bool
  default     = false
}

variable "kms_key_arn" {
  description = "DMS replication instance KMS key ARN (옵션)"
  type        = string
  default     = null
}

variable "preferred_maintenance_window" {
  description = "DMS replication instance maintenance window (옵션)"
  type        = string
  default     = null
}

# =================
# Source endpoint
# =================
variable "source_engine_name" {
  description = "DMS source endpoint engine_name (mysql, postgres, sqlserver, oracle 등)"
  type        = string
}

variable "source_server_name" {
  description = "DMS source endpoint server_name (IP 또는 DNS)"
  type        = string
}

variable "source_port" {
  description = "DMS source endpoint port"
  type        = number
  default     = 3306
}

variable "source_database_name" {
  description = "DMS source endpoint database_name"
  type        = string
  default     = ""
}

variable "source_username" {
  description = "DMS source endpoint username"
  type        = string
}

variable "source_password" {
  description = "DMS source endpoint password"
  type        = string
  sensitive   = true
}

variable "source_ssl_mode" {
  description = "DMS source endpoint ssl_mode (none | require | verify-ca | verify-full)"
  type        = string
  default     = "none"
}

variable "source_extra_connection_attributes" {
  description = "DMS source endpoint extra_connection_attributes (옵션)"
  type        = string
  default     = null
}

# =================
# Target endpoint
# =================
variable "target_engine_name" {
  description = "DMS target endpoint engine_name (aurora, aurora-postgresql, mysql, postgres 등)"
  type        = string
}

variable "target_server_name" {
  description = "DMS target endpoint server_name (Aurora/RDS endpoint)"
  type        = string
}

variable "target_port" {
  description = "DMS target endpoint port"
  type        = number
  default     = 3306
}

variable "target_database_name" {
  description = "DMS target endpoint database_name"
  type        = string
  default     = ""
}

variable "target_username" {
  description = "DMS target endpoint username"
  type        = string
}

variable "target_password" {
  description = "DMS target endpoint password"
  type        = string
  sensitive   = true
}

variable "target_ssl_mode" {
  description = "DMS target endpoint ssl_mode (none | require | verify-ca | verify-full)"
  type        = string
  default     = "none"
}

variable "target_extra_connection_attributes" {
  description = "DMS target endpoint extra_connection_attributes (옵션)"
  type        = string
  default     = null
}

# =================
# Replication task
# =================
variable "migration_type" {
  description = "DMS migration_type (full-load | cdc | full-load-and-cdc)"
  type        = string
  default     = "full-load"
}

variable "table_mappings" {
  description = "DMS table mappings JSON"
  type        = string
}

variable "replication_task_settings" {
  description = "DMS replication task settings JSON (옵션). null이면 AWS 기본값"
  type        = string
  default     = null
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}


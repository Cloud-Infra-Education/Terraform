variable "infra_state_path" {
  type        = string
  default     = "../01-infra/terraform.tfstate"
}

variable "database_state_path" {
  type        = string
  default     = "../03-database/terraform.tfstate"
}

# ================
# DB 클러스터 계정
# ================
variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "dms_source_engine_name" {
  type        = string
  default     = "mysql"
}

variable "dms_source_server_name" {
  type        = string
  default     = ""
}

variable "dms_source_port" {
  type        = number
  default     = 3306
}

variable "dms_source_database_name" {
  type        = string
  default     = ""
}

variable "dms_source_username" {
  type        = string
}

variable "dms_source_password" {
  type        = string
  sensitive   = true
}

variable "dms_source_ssl_mode" {
  type        = string
  default     = "none"
}

variable "dms_target_database_name" {
  type        = string
  default     = ""
}

variable "dms_target_ssl_mode" {
  type        = string
  default     = "none"
}

variable "dms_migration_type" {
  type        = string
  default     = "full-load"
}

variable "dms_table_mappings" {
  description = "DMS table mappings JSON"
  type        = string
  default     = <<JSON
{
  "rules": [
    {
      "rule-type": "selection",
      "rule-id": "1",
      "rule-name": "one-scheme-can-be-migrated",
      "object-locator": {
        "schema-name": "ott_db",
        "table-name": "%"
      },
      "rule-action": "include"
    }
  ]
}
JSON
}

variable "dms_replication_task_settings" {
  type        = string
  default     = null
}


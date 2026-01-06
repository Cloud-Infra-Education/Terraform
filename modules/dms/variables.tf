variable "source_db_endpoint" {
  type = string
}

variable "target_db_endpoint" {
  type = string
}

variable "db_port" {
  type    = number
  default = 3306
}

variable "source_db_sg_id" {
  type = string
}

variable "target_db_sg_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "source_db_name" {
  description = "Source database name for DMS replication"
  type        = string
}

variable "target_db_name" {
  description = "Target database name for DMS replication"
  type        = string
}

variable "db_kor_cluster_id" {
  type        = string
  description = "KOR Aurora cluster ID for DMS dependency"
}

variable "db_usa_cluster_id" {
  type        = string
  description = "USA Aurora cluster ID for DMS dependency"
}

variable "our_team" {
  type = string
}

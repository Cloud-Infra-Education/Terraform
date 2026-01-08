# ===============================
# 1 온프레미스 DB
# ===============================
variable "onprem_db_endpoint" {
  type = string
}

variable "onprem_db_port" {
  type    = number
  default = 3306
}

variable "onprem_db_name" {
  type = string
}

variable "onprem_db_username" {
  type = string
}

variable "onprem_db_password" {
  type      = string
  sensitive = true
}

variable "onprem_cidr" {
  type = string
}

# ===============================
# 2 리전 DB (서울 + 미국)
# ===============================
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

variable "dms_db_username" {
  type        = string
  description = "DMS replication user for Aurora clusters"
}

variable "dms_db_password" {
  type        = string
  description = "Password for DMS replication user"
  sensitive   = true
}

variable "source_db_name" {
  type = string
}

variable "target_db_name" {
  type = string
}

variable "db_kor_cluster_id" {
  type = string
}

variable "db_usa_cluster_id" {
  type = string
}

# ===============================
# 3 기타
# ===============================
variable "our_team" {
  type = string
}


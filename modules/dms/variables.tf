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


variable "db_username" {
  description = "DB master username"
  type = string
}

variable "db_password" {
  description = "DB master password"
  type      = string
  sensitive = true
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

variable "seoul_eks_workers_sg_id" {
  type = string
}
variable "oregon_eks_workers_sg_id" {
  type = string
}

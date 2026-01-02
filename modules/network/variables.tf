variable "key_name_kor" {
  description = "EC2 Key Pair in Seoul Region"
  type        = string
}

variable "key_name_usa" {
  description = "EC2 Key Pair in Oregon Region"
  type        = string
}

variable "admin_cidr" {
  type = string
}

variable "onprem_public_ip" {
  type = string
}

variable "onprem_private_cidr" {
  type = string
}

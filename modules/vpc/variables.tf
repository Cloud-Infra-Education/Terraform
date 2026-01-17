variable "name" {}
variable "cidr" {}
variable "azs" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "key_name" {}
variable "instance_type" {
  default = "t3.micro"
}
variable "admin_cidr" {}
variable "public_subnet_names" {}
variable "private_subnet_names" {}


variable "tgw_id" { default = " "}
variable "tgw_subnets" { default = " "}
variable "peer_vpc_cidr" {default = " "}
variable "tgw_subnet_names" { default =  " " }

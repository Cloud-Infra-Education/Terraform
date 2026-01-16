output "kor_vpc_id" {
  value = module.kor_vpc.vpc_id
}
output "usa_vpc_id" {
  value = module.usa_vpc.vpc_id
}

output "kor_private_eks_subnet_ids" {
  value = module.kor_vpc.private_eks_subnet_ids
}
output "usa_private_eks_subnet_ids" {
  value = module.usa_vpc.private_eks_subnet_ids
}

output "kor_private_db_subnet_ids" {
  value = module.kor_vpc.private_db_subnet_ids
}
output "usa_private_db_subnet_ids" {
  value = module.usa_vpc.private_db_subnet_ids
}

output "kor_bastion_security_group_id" {
  value = module.kor_vpc.bastion_security_group_id
}

output "usa_bastion_security_group_id" {
  value = module.usa_vpc.bastion_security_group_id
}

output "kor_bastion_public_ip" {
  value = module.kor_vpc.bastion_public_ip
}

output "usa_bastion_public_ip" {
  value = module.usa_vpc.bastion_public_ip
}

output "kor_bastion_instance_id" {
  value = module.kor_vpc.bastion_instance_id
}

output "usa_bastion_instance_id" {
  value = module.usa_vpc.bastion_instance_id
}

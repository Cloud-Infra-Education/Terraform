output "kor_vpc_id" {
  value = module.network.kor_vpc_id
}

output "usa_vpc_id" {
  value = module.network.usa_vpc_id
}

output "kor_private_eks_subnet_ids" {
  value = module.network.kor_private_eks_subnet_ids
}

output "usa_private_eks_subnet_ids" {
  value = module.network.usa_private_eks_subnet_ids
}

output "kor_private_db_subnet_ids" {
  value = module.network.kor_private_db_subnet_ids
}

output "usa_private_db_subnet_ids" {
  value = module.network.usa_private_db_subnet_ids
}

output "origin_bucket_name" {
  value = module.s3.origin_bucket_name
}

output "kor_vpc_cidr" {
  value = module.network.kor_vpc_cidr
}

output "usa_vpc_cidr" {
  value = module.network.usa_vpc_cidr
}

output "kor_tgw_id" {
  value = module.network.kor_tgw_id
}

output "kor_tgw_association_default_route_table_id" {
  value = module.network.kor_tgw_association_default_route_table_id
}

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

output "kor_private_route_table_ids" {
  value = module.kor_vpc.private_route_table_ids
}

output "usa_private_route_table_ids" {
  value = module.usa_vpc.private_route_table_ids
}

output "kor_tgw_id" {
  value = aws_ec2_transit_gateway.kor.id
}

output "usa_tgw_id" {
  value = aws_ec2_transit_gateway.usa.id
}

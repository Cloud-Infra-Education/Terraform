output "kor_vpc_id" {
  value = module.kor_vpc.vpc_id
}

output "kor_private_eks_subnet_ids" {
  value = module.kor_vpc.private_eks_subnet_ids
}

output "usa_vpc_id" {
  value = module.usa_vpc.vpc_id
}

output "usa_private_eks_subnet_ids" {
  value = module.usa_vpc.private_eks_subnet_ids
}

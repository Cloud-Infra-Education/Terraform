# ============================================================
# - database (Aurora + RDS Proxy)
# - 01-infra (VPC/Subnet) + 02-kubernetes (EKS Worker SG) outputs를 참조
# ============================================================

module "database" {
  source = "../modules/database"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  kor_vpc_id                = data.terraform_remote_state.infra.outputs.kor_vpc_id
  usa_vpc_id                = data.terraform_remote_state.infra.outputs.usa_vpc_id
  kor_private_db_subnet_ids = data.terraform_remote_state.infra.outputs.kor_private_db_subnet_ids
  usa_private_db_subnet_ids = data.terraform_remote_state.infra.outputs.usa_private_db_subnet_ids

  seoul_eks_workers_sg_id  = data.terraform_remote_state.kubernetes.outputs.seoul_eks_workers_sg_id
  oregon_eks_workers_sg_id = data.terraform_remote_state.kubernetes.outputs.oregon_eks_workers_sg_id

  db_username     = var.db_username
  db_password     = var.db_password
  dms_db_username = var.dms_db_username
  dms_db_password = var.dms_db_password

  our_team = var.our_team

  onprem_public_ip    = var.onprem_public_cidr
  onprem_private_cidr = var.onprem_private_cidr
}

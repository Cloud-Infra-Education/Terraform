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

  db_username = var.db_username
  db_password = var.db_password
  our_team    = var.our_team
}

module "cloudwatch" {
  source = "./modules/cloudwatch"

  providers = {
    aws.seoul = aws.seoul
  }

  our_team           = var.our_team
  db_instance_id     = module.database.db_instance_id
  ecr_url_alert      = data.terraform_remote_state.kubernetes.outputs.user_service_repository_url
  slack_secret_name  = "${var.our_team}/slack/webhook"
}


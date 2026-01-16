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

  seoul_bastion_sg_id  = data.terraform_remote_state.infra.outputs.kor_bastion_security_group_id
  oregon_bastion_sg_id = data.terraform_remote_state.infra.outputs.usa_bastion_security_group_id

  db_username = var.db_username
  db_password = var.db_password
  our_team    = var.our_team
}

# ============================================================
# - Lambda Video Processor
# - S3에 비디오 업로드 시 자동 처리
# ============================================================

module "lambda_video_processor" {
  source = "../modules/lambda"

  providers = {
    aws.seoul = aws.seoul
  }

  vpc_id             = data.terraform_remote_state.infra.outputs.kor_vpc_id
  private_subnet_ids = data.terraform_remote_state.infra.outputs.kor_private_db_subnet_ids

  origin_bucket_id   = data.terraform_remote_state.infra.outputs.origin_bucket_name
  origin_bucket_arn  = "arn:aws:s3:::${data.terraform_remote_state.infra.outputs.origin_bucket_name}"
  origin_bucket_name = data.terraform_remote_state.infra.outputs.origin_bucket_name

  catalog_api_base  = var.catalog_api_base
  internal_token    = var.internal_token
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  db_host           = try(module.database.kor_db_proxy_endpoint, "")
  cloudfront_domain = var.cloudfront_domain
  tmdb_api_key      = var.tmdb_api_key
}

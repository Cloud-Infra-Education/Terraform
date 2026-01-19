# ============================================================
# - datasync (Aurora + RDS Proxy)
# - 01-infra (VPC/Subnet) + 02-kubernetes (EKS Worker SG) outputs를 참조
# ============================================================

module "datasync" {
  source = "../modules/datasync"

  # Provider 전달
  providers = {
    aws = aws.seoul
  }

  # 변수 전달
  our_team               = var.our_team
#  vpc_id                 = data.terraform_remote_state.infra.outputs.kor_vpc_id

  target_bucket_arn = "arn:aws:s3:::${data.terraform_remote_state.infra.outputs.origin_bucket_name}"
  onprem_private_ip       = var.onprem_private_ip
  onprem_mg_private_cidr = var.onprem_private_cidr
  datasync_agent_arn     = var.datasync_agent_arn
  onprem_source_path     = "/mnt/my_data" # 필요 시 수정
}

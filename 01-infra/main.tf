# ============================================================
# 01-infra
# - network(vpc 포함), s3
# ============================================================

module "network" {
  source = "../modules/network"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  key_name_kor        = var.key_name_kor
  key_name_usa        = var.key_name_usa
  admin_cidr          = var.admin_cidr
  onprem_public_ip    = var.onprem_public_ip
  onprem_private_cidr = var.onprem_private_cidr
}

module "s3" {
  source = "../modules/s3"

  origin_bucket_name = var.origin_bucket_name
}

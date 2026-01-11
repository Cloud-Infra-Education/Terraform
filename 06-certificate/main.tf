# ============================================================
# - ACM(Seoul/Oregon/us-east-1), WAFv2
# ============================================================

module "acm" {
  source = "../modules/acm"

  providers = {
    aws.acm    = aws.acm
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  our_team           = var.our_team
  domain_name        = var.domain_name
  origin_bucket_name = data.terraform_remote_state.infra.outputs.origin_bucket_name
}

module "waf" {
  source = "../modules/waf"

  providers = {
    aws.acm    = aws.acm
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  our_team    = var.our_team
  domain_name = var.domain_name
}

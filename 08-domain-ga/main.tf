# ============================================================
# - Global Accelerator + api.<domain> A 레코드
# ============================================================

module "ga" {
  source = "../modules/ga"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  depends_on = [data.terraform_remote_state.domain_cf]

  ga_name              = var.ga_name
  domain_name          = var.domain_name
  route53_zone_id       = var.route53_zone_id
  alb_lookup_tag_value = var.alb_lookup_tag_value
}

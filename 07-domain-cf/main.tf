# ============================================================
# - Route53, ACM ISSUE, CloudFront, Ingress(ALB)
# ============================================================

module "domain" {
  source = "../modules/domain"

  providers = {
    aws              = aws.oregon
    aws.seoul        = aws.seoul
    aws.oregon       = aws.oregon
    aws.acm          = aws.acm
    kubernetes        = kubernetes
    kubernetes.oregon = kubernetes.oregon
  }

  our_team    = var.our_team
  domain_name = var.domain_name

  origin_bucket_name = data.terraform_remote_state.infra.outputs.origin_bucket_name

  cloudfront_waf_web_acl_arn = data.terraform_remote_state.certificate.outputs.cloudfront_waf_web_acl_arn
  seoul_waf_web_acl_arn      = data.terraform_remote_state.certificate.outputs.seoul_waf_web_acl_arn
  oregon_waf_web_acl_arn     = data.terraform_remote_state.certificate.outputs.oregon_waf_web_acl_arn

  acm_arn_api_seoul  = data.terraform_remote_state.certificate.outputs.acm_arn_api_seoul
  acm_arn_api_oregon = data.terraform_remote_state.certificate.outputs.acm_arn_api_oregon
  acm_arn_www        = data.terraform_remote_state.certificate.outputs.acm_arn_www

  dvo_api_seoul  = data.terraform_remote_state.certificate.outputs.dvo_api_seoul
  dvo_api_oregon = data.terraform_remote_state.certificate.outputs.dvo_api_oregon
  dvo_www        = data.terraform_remote_state.certificate.outputs.dvo_www
}

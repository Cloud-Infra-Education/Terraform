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

  # cloudfront_waf_web_acl_arn = data.terraform_remote_state.certificate.outputs.cloudfront_waf_web_acl_arn
  # seoul_waf_web_acl_arn      = data.terraform_remote_state.certificate.outputs.seoul_waf_web_acl_arn
  # oregon_waf_web_acl_arn     = data.terraform_remote_state.certificate.outputs.oregon_waf_web_acl_arn

  acm_arn_api_seoul  = data.terraform_remote_state.certificate.outputs.acm_arn_api_seoul
  acm_arn_api_oregon = data.terraform_remote_state.certificate.outputs.acm_arn_api_oregon
  acm_arn_www        = data.terraform_remote_state.certificate.outputs.acm_arn_www
  # Keycloak 인증서 ARN (직접 AWS에서 조회한 값 사용, outputs가 없을 경우)
  acm_arn_keycloak_seoul  = "arn:aws:acm:ap-northeast-2:404457776061:certificate/f1306332-52d2-4da8-930e-71514390b5ed"
  acm_arn_keycloak_oregon = try(data.terraform_remote_state.certificate.outputs.acm_arn_keycloak_oregon, "")

  dvo_api_seoul  = data.terraform_remote_state.certificate.outputs.dvo_api_seoul
  dvo_api_oregon = data.terraform_remote_state.certificate.outputs.dvo_api_oregon
  dvo_www        = data.terraform_remote_state.certificate.outputs.dvo_www
  # Keycloak DVO (없을 경우 빈 리스트)
  dvo_keycloak_seoul  = try(data.terraform_remote_state.certificate.outputs.dvo_keycloak_seoul, [])
  dvo_keycloak_oregon = try(data.terraform_remote_state.certificate.outputs.dvo_keycloak_oregon, [])

  keycloak_subdomain = "keycloak"
}

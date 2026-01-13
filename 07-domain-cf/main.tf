# ============================================================
# - Route53, ACM ISSUE, CloudFront, Ingress(ALB)
# ============================================================

module "domain" {
  source = "../modules/domain"

  # 프로바이더 매핑: 부모의 설정을 자식 모듈의 별칭에 연결합니다.
  providers = {
    aws               = aws.oregon
    aws.seoul         = aws.seoul
    aws.oregon        = aws.oregon
    aws.acm           = aws.acm
    kubernetes.seoul  = kubernetes.seoul  # [수정] 서울 클러스터 연결
    kubernetes.oregon = kubernetes.oregon # [수정] 오레곤 클러스터 연결
  }

  # 변수 설정
  our_team    = var.our_team
  domain_name = var.domain_name

  # Remote State에서 데이터 가져오기
  origin_bucket_name = data.terraform_remote_state.infra.outputs.origin_bucket_name

  # 보안(WAF) 설정
  cloudfront_waf_web_acl_arn = data.terraform_remote_state.certificate.outputs.cloudfront_waf_web_acl_arn
  seoul_waf_web_acl_arn      = data.terraform_remote_state.certificate.outputs.seoul_waf_web_acl_arn
  oregon_waf_web_acl_arn     = data.terraform_remote_state.certificate.outputs.oregon_waf_web_acl_arn

  # 인증서(ACM) 설정
  acm_arn_api_seoul  = data.terraform_remote_state.certificate.outputs.acm_arn_api_seoul
  acm_arn_api_oregon = data.terraform_remote_state.certificate.outputs.acm_arn_api_oregon
  acm_arn_www        = data.terraform_remote_state.certificate.outputs.acm_arn_www

  # 도메인 검증 정보
  dvo_api_seoul  = data.terraform_remote_state.certificate.outputs.dvo_api_seoul
  dvo_api_oregon = data.terraform_remote_state.certificate.outputs.dvo_api_oregon
  dvo_www        = data.terraform_remote_state.certificate.outputs.dvo_www
}

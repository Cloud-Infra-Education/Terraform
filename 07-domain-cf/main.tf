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

  our_team        = var.our_team
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id

  origin_bucket_name = data.terraform_remote_state.infra.outputs.origin_bucket_name

  # Backend API 배포 관련 변수
  ecr_repository_url = var.ecr_repository_url

  # Database 관련 변수
  kor_db_proxy_endpoint = data.terraform_remote_state.database.outputs.kor_db_proxy_endpoint
  db_username           = var.db_username
  db_password           = var.db_password
  db_name              = var.db_name

  # cloudfront_waf_web_acl_arn = data.terraform_remote_state.certificate.outputs.cloudfront_waf_web_acl_arn
  # seoul_waf_web_acl_arn      = data.terraform_remote_state.certificate.outputs.seoul_waf_web_acl_arn
  # oregon_waf_web_acl_arn     = data.terraform_remote_state.certificate.outputs.oregon_waf_web_acl_arn

  acm_arn_api_seoul  = data.terraform_remote_state.certificate.outputs.acm_arn_api_seoul
  acm_arn_api_oregon = data.terraform_remote_state.certificate.outputs.acm_arn_api_oregon
  acm_arn_www        = data.terraform_remote_state.certificate.outputs.acm_arn_www

  dvo_api_seoul  = data.terraform_remote_state.certificate.outputs.dvo_api_seoul
  dvo_api_oregon = data.terraform_remote_state.certificate.outputs.dvo_api_oregon
  dvo_www        = data.terraform_remote_state.certificate.outputs.dvo_www

  # EKS 클러스터 이름 (IRSA용)
  eks_cluster_name = data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name
}

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

  # [추가됨] GA가 로그를 쌓을 S3 버킷 이름을 모듈에 전달합니다.
  origin_bucket_name = data.terraform_remote_state.infra.outputs.origin_bucket_name

  ga_name              = var.ga_name
  domain_name          = var.domain_name
  alb_lookup_tag_value = var.alb_lookup_tag_value
}

# ============================================================
# - Global Accelerator + api.<domain> A 레코드
# - 수정 사항: GA 전용 로그 버킷(ga-logs) 연결 적용
# ============================================================

module "ga" {
  source = "../modules/ga"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  depends_on = [data.terraform_remote_state.domain_cf]

<<<<<<< Updated upstream
=======
  # [수정] 팀장님 지시사항: 기존 origin_bucket_name 대신 GA 전용 로그 버킷을 전달합니다.
  origin_bucket_name = data.terraform_remote_state.infra.outputs.bucket_ga_logs

>>>>>>> Stashed changes
  ga_name              = var.ga_name
  domain_name          = var.domain_name
  alb_lookup_tag_value = var.alb_lookup_tag_value
}

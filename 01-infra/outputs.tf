# ============================================================
# 01-infra 단계 최종 출력 설정
# - 다른 모듈(07-domain-cf, 08-domain-ga)에서 참조할 수 있도록 로그 버킷 추가
# ============================================================

output "kor_vpc_id" {
  value = module.network.kor_vpc_id
}

output "usa_vpc_id" {
  value = module.network.usa_vpc_id
}

output "kor_private_eks_subnet_ids" {
  value = module.network.kor_private_eks_subnet_ids
}

output "usa_private_eks_subnet_ids" {
  value = module.network.usa_private_eks_subnet_ids
}

output "kor_private_db_subnet_ids" {
  value = module.network.kor_private_db_subnet_ids
}

output "usa_private_db_subnet_ids" {
  value = module.network.usa_private_db_subnet_ids
}

# ------------------------------------------------------------
# S3 버킷 출력 (모듈에서 받아와서 루트로 내보냄)
# ------------------------------------------------------------
output "origin_bucket_name" {
  value = module.s3.origin_bucket_name
}

# [추가] CloudFront 전용 로그 버킷
output "bucket_cloudfront_logs" {
  value = module.s3.bucket_cloudfront_logs
}

# [추가] Global Accelerator 전용 로그 버킷
output "bucket_ga_logs" {
  value = module.s3.bucket_ga_logs
}

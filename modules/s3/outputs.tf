# 1) 원본 데이터 버킷 출력 (CloudFront 오리진용)
output "origin_bucket_name" {
  description = "원본 데이터 S3 버킷 이름"
  value       = aws_s3_bucket.this.id
}

output "bucket_regional_domain_name" {
  description = "CloudFront OAC 설정에 필요한 버킷의 지역 도메인 이름"
  value       = aws_s3_bucket.this.bucket_regional_domain_name
}

output "bucket_arn" {
  description = "S3 버킷 정책(IAM) 설정에 필요한 ARN"
  value       = aws_s3_bucket.this.arn
}

# 2) CloudFront 로그 전용 버킷 출력 (07-domain-cf 모듈에서 참조)
output "bucket_cloudfront_logs" {
  description = "CloudFront 접속 로그가 저장될 버킷 이름"
  value       = aws_s3_bucket.cf_logs.id
}

# 3) Global Accelerator 로그 전용 버킷 출력 (08-domain-ga 모듈에서 참조)
output "bucket_ga_logs" {
  description = "Global Accelerator Flow Logs가 저장될 버킷 이름"
  value       = aws_s3_bucket.ga_logs.id
}

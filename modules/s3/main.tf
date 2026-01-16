# ------------------------------------------------------------
# 1) 원본 데이터 버킷 (기존)
# ------------------------------------------------------------
resource "aws_s3_bucket" "this" {
<<<<<<< Updated upstream
  bucket = var.origin_bucket_name 
=======
  bucket = var.origin_bucket_name

  # 로그 분석을 위한 버전 관리 활성화
  versioning {
    enabled = true
  }
}

# 객체 소유권 설정 (로그 서비스 연동을 위해 필수)
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
>>>>>>> Stashed changes
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------
# 2) CloudFront 전용 로그 버킷 (신규 추가)
# ------------------------------------------------------------
resource "aws_s3_bucket" "cf_logs" {
  bucket = "${var.origin_bucket_name}-cf-logs"
}

# CloudFront 로그 전달 서비스가 파일을 쓸 수 있도록 소유권 설정
resource "aws_s3_bucket_ownership_controls" "cf_logs" {
  bucket = aws_s3_bucket.cf_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "cf_logs" {
  bucket = aws_s3_bucket.cf_logs.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------
# 3) Global Accelerator 전용 로그 버킷 (신규 추가)
# ------------------------------------------------------------
resource "aws_s3_bucket" "ga_logs" {
  bucket = "${var.origin_bucket_name}-ga-logs"
}

# GA Flow Logs가 저장될 때의 소유권 문제 방지
resource "aws_s3_bucket_ownership_controls" "ga_logs" {
  bucket = aws_s3_bucket.ga_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "ga_logs" {
  bucket = aws_s3_bucket.ga_logs.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

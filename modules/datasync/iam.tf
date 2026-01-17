# DataSync 서비스 Role
resource "aws_iam_role" "this" {
  name = "${var.our_team}-datasync-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "datasync.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "${var.our_team}-datasync-s3-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        # 버킷 자체에 대한 권한 (List 등)
        Action   = ["s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads"]
        Effect   = "Allow"
        Resource = var.target_bucket_arn
      },
      {
        # 버킷 내부 객체에 대한 권한 (Put, Get 등)
        Action   = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:ListMultipartUploadParts", "s3:PutObject", "s3:Tagging"]
        Effect   = "Allow"
        Resource = "${var.target_bucket_arn}/*"
      }
    ]
  })
}

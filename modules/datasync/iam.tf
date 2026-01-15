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

# S3 접근 권한 Policy
resource "aws_iam_role_policy" "s3_access" {
  name = "${var.our_team}-datasync-s3-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads"]
        Effect = "Allow"
        Resource = aws_s3_bucket.migration_target.arn
      },
      {
        Action = ["s3:AbortMultipartUpload", "s3:DeleteObject", "s3:GetObject", "s3:ListMultipartUploadParts", "s3:PutObject", "s3:Tagging"]
        Effect = "Allow"
        Resource = "${aws_s3_bucket.migration_target.arn}/*"
      }
    ]
  })
}

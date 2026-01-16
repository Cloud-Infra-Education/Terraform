# IAM Role for Lambda
resource "aws_iam_role" "video_exec" {
  name = "yuh-formation-lap-video-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "yuh-formation-lap-video-processor-role"
  }
}

# Lambda 기본 실행 권한
resource "aws_iam_role_policy_attachment" "video_basic" {
  role       = aws_iam_role.video_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda VPC 실행 권한
resource "aws_iam_role_policy_attachment" "video_vpc" {
  role       = aws_iam_role.video_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# S3 읽기 권한
resource "aws_iam_role_policy" "video_s3_read" {
  name = "yuh-formation-lap-video-s3-read"
  role = aws_iam_role.video_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${var.origin_bucket_arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${var.origin_bucket_arn}/thumbnails/*"
      }
    ]
  })
}

# RDS Data API 권한 (선택사항)
# Resource ARN이 있을 때만 생성
resource "aws_iam_role_policy" "video_rds" {
  count = (var.db_resource_arn != "" || var.db_secret_arn != "") ? 1 : 0
  name  = "yuh-formation-lap-video-rds"
  role  = aws_iam_role.video_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # RDS Data API 권한 (Resource ARN이 있을 때만)
      var.db_resource_arn != "" ? [{
        Effect   = "Allow"
        Action   = ["rds-data:ExecuteStatement", "rds-data:BatchExecuteStatement"]
        Resource = var.db_resource_arn
      }] : [],
      # Secrets Manager 권한 (Secret ARN이 있을 때만)
      var.db_secret_arn != "" ? [{
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.db_secret_arn
      }] : []
    )
  })
}

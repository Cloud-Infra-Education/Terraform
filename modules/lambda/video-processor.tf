# Lambda Function for Video Processing
resource "aws_lambda_function" "video_processor" {
  filename         = "${path.module}/lambda-function.zip"
  function_name    = "yuh-formation-lap-video-processor"
  role            = aws_iam_role.video_exec.arn
  handler         = "app.lambda_handler"
  runtime         = "python3.11"
  timeout         = 300
  memory_size     = 1024

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      CATALOG_API_BASE  = var.catalog_api_base
      INTERNAL_TOKEN    = var.internal_token
      DB_NAME           = var.db_name
      DB_USER           = var.db_username
      DB_PASSWORD       = var.db_password
      DB_HOST           = var.db_host
      S3_BUCKET         = var.origin_bucket_name
      S3_REGION         = "ap-northeast-2"
      CLOUDFRONT_DOMAIN = var.cloudfront_domain
      TMDB_API_KEY      = var.tmdb_api_key
    }
  }

  # FFmpeg Layer 추가
  layers = [aws_lambda_layer_version.ffmpeg.arn]

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.video_vpc,
    aws_iam_role_policy_attachment.video_basic,
    aws_cloudwatch_log_group.lambda_logs
  ]

  tags = {
    Name = "yuh-formation-lap-video-processor"
  }
}

# Lambda Layer for FFmpeg
resource "null_resource" "ffmpeg_layer_build" {
  triggers = {
    build_script_hash = filemd5("${path.module}/build-ffmpeg-layer.sh")
  }

  provisioner "local-exec" {
    command = "${path.module}/build-ffmpeg-layer.sh"
  }
}

# S3에 업로드된 FFmpeg Layer 사용
resource "aws_lambda_layer_version" "ffmpeg" {
  depends_on = [null_resource.ffmpeg_layer_build]
  
  s3_bucket   = var.origin_bucket_name
  s3_key      = "lambda-layers/ffmpeg-layer.zip"
  layer_name  = "yuh-formation-lap-ffmpeg-layer"
  compatible_runtimes = ["python3.11"]
  
  source_code_hash = filebase64sha256("${path.module}/ffmpeg-layer.zip")
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/yuh-formation-lap-video-processor"
  retention_in_days = 7
}

# Lambda ZIP 파일 빌드 (의존성 포함)
resource "null_resource" "lambda_build" {
  triggers = {
    source_hash = filemd5("${path.root}/../../Backend/lambda/video-processor/app.py")
    requirements_hash = filemd5("${path.root}/../../Backend/lambda/video-processor/requirements.txt")
  }

  provisioner "local-exec" {
    command = "${path.module}/build-lambda.sh"
  }
}

# Lambda ZIP 파일 (빌드된 파일 사용)
data "archive_file" "lambda_zip" {
  depends_on = [null_resource.lambda_build]
  type        = "zip"
  source_file = "${path.module}/lambda-function.zip"
  output_path = "${path.module}/lambda-function.zip"
}

# S3 이벤트 트리거
# Lambda 함수가 완전히 생성되고 권한이 설정된 후에 notification 설정
# VPC 내부 Lambda는 생성 시간이 오래 걸릴 수 있으므로 명시적 depends_on 필요
resource "aws_s3_bucket_notification" "video_trigger" {
  bucket = var.origin_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.video_processor.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:CompleteMultipartUpload"]
    filter_prefix       = "videos/"
    filter_suffix       = ".mp4"
  }

  # Lambda 함수가 완전히 생성되고 활성화된 후에 설정
  depends_on = [
    aws_lambda_function.video_processor,
    aws_lambda_permission.allow_s3,
    aws_iam_role_policy_attachment.video_vpc,
    aws_iam_role_policy_attachment.video_basic
  ]
}

# Lambda 권한 (S3가 Lambda 호출 가능하도록)
# Lambda 함수가 생성된 후에 권한 설정
# source_arn은 버킷 ARN만 사용 (/* 제거)
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.origin_bucket_arn

  depends_on = [aws_lambda_function.video_processor]
}

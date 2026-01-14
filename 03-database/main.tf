# ============================================================
# - database (Aurora + RDS Proxy)
# - 01-infra (VPC/Subnet) + 02-kubernetes (EKS Worker SG) outputs를 참조
# - Lambda IAM 역할 (video processor용)
# ============================================================

module "database" {
  source = "../modules/database"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  kor_vpc_id                = data.terraform_remote_state.infra.outputs.kor_vpc_id
  usa_vpc_id                = data.terraform_remote_state.infra.outputs.usa_vpc_id
  kor_private_db_subnet_ids = data.terraform_remote_state.infra.outputs.kor_private_db_subnet_ids
  usa_private_db_subnet_ids = data.terraform_remote_state.infra.outputs.usa_private_db_subnet_ids

  seoul_eks_workers_sg_id  = data.terraform_remote_state.kubernetes.outputs.seoul_eks_workers_sg_id
  oregon_eks_workers_sg_id = data.terraform_remote_state.kubernetes.outputs.oregon_eks_workers_sg_id

  db_username = var.db_username
  db_password = var.db_password
  our_team    = var.our_team
  db_name     = var.db_name
}

# Lambda 함수용 IAM 역할 (video processor)
resource "aws_iam_role" "video_exec" {
  name = "${var.our_team}-video-processor-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "video_vpc" {
  role       = aws_iam_role.video_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "video_custom" {
  name = "${var.our_team}-video-custom-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:HeadObject",
          "s3:GetObjectTagging"
        ]
        Resource = ["${data.terraform_remote_state.infra.outputs.origin_bucket_arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "video_custom_attach" {
  role       = aws_iam_role.video_exec.name
  policy_arn = aws_iam_policy.video_custom.arn
}

# Lambda 함수 (video processor)
resource "aws_lambda_function" "video_processor" {
  function_name = "${var.our_team}-video-processor"
  package_type  = "Image"
  image_uri     = "${data.terraform_remote_state.kubernetes.outputs.video_processor_repo_url}:v1"
  role          = aws_iam_role.video_exec.arn
  timeout       = 600  # 10분 (VPC 내 S3 접근 + FFmpeg 처리 고려)
  memory_size   = 2048

  vpc_config {
    subnet_ids         = data.terraform_remote_state.infra.outputs.kor_private_eks_subnet_ids
    security_group_ids = [module.database.lambda_sg_id]
  }

  environment {
    variables = {
      DB_HOST          = module.database.proxy_endpoint
      DB_USER          = var.db_username
      DB_PASSWORD      = var.db_password
      DB_NAME          = "ott_db"
      CATALOG_API_BASE = var.catalog_api_base  # FastAPI 도메인 (예: https://api.matchacake.click/api)
      INTERNAL_TOKEN   = var.internal_token    # FastAPI와 공유하는 내부 토큰
      TMDB_API_KEY     = var.tmdb_api_key      # TMDB API 키 (선택사항)
    }
  }
}

# S3에서 Lambda 함수 호출 권한
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.video_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = data.terraform_remote_state.infra.outputs.origin_bucket_arn
}

# S3 버킷 알림 설정 (Lambda 함수 트리거)
resource "aws_s3_bucket_notification" "video_trigger" {
  bucket = data.terraform_remote_state.infra.outputs.origin_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.video_processor.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "videos/"
    filter_suffix       = ".mp4"
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

# 초기 데이터베이스 스키마 실행 (ott_db 테이블 생성)
# 주의: RDS Proxy를 통해 실행되므로 VPC 내부 네트워크 접근이 필요합니다.
# MySQL 클라이언트가 설치되어 있어야 합니다: apt-get install -y mysql-client
# 현재 서버에서 RDS Proxy에 직접 접근할 수 없는 경우, 이 리소스는 주석 처리하고
# bastion을 통해 수동으로 스키마를 초기화하세요:
# mysql -h <proxy-endpoint> -u <username> -p <db_name> < ../modules/database/init.sql
# resource "null_resource" "init_database_schema" {
#   triggers = {
#     cluster_endpoint = module.database.proxy_endpoint
#     init_sql_hash    = filemd5("${path.module}/../modules/database/init.sql")
#   }
#
#   provisioner "local-exec" {
#     command = <<-EOT
#       mysql -h ${module.database.proxy_endpoint} \
#         -u ${var.db_username} \
#         -p${var.db_password} \
#         ${var.db_name} \
#         < ${path.module}/../modules/database/init.sql
#     EOT
#   }
#
#   depends_on = [
#     module.database
#   ]
# }

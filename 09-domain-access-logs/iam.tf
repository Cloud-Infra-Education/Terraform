# Lambda 실행 역할
resource "aws_iam_role" "lambda_exec_role" {
  name = "route53-dns-log-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "Route53 DNS Log Lambda Role"
  }
}

# Lambda 기본 실행 정책: CloudWatch Logs에 로그 작성
resource "aws_iam_role_policy" "lambda_basic_execution" {
  name = "lambda-basic-execution"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.lambda_function_name}:*"
      }
    ]
  })
}

# Lambda OpenSearch 접근 정책
resource "aws_iam_role_policy" "lambda_opensearch_access" {
  name = "lambda-opensearch-access"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "es:ESHttpPost",
          "es:ESHttpPut"
        ]
        Resource = "${aws_opensearch_domain.route53_logs.arn}/${var.opensearch_index_name}/*"
      }
    ]
  })
}

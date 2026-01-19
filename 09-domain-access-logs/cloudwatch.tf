# CloudWatch Log Group: Route53 Query Logs 저장소
# Route53 Query Logging은 CloudWatch Logs가 us-east-1에 있어야 함
resource "aws_cloudwatch_log_group" "route53_query_logs" {
  provider = aws.us_east_1

  name              = "/aws/route53/query-logs"
  retention_in_days = var.log_retention_days

  tags = {
    Name = "Route53 Query Logs"
  }
}

# CloudWatch Logs Resource Policy: Route53이 로그를 쓸 수 있도록 허용
resource "aws_cloudwatch_log_resource_policy" "route53_logs_policy" {
  provider = aws.us_east_1

  policy_name = "route53-query-logging-policy"

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "route53.amazonaws.com"
        }
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.route53_query_logs.arn}:*"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.us_east_1.account_id
          }
        }
      }
    ]
  })
}

# us-east-1 리전의 AWS 계정 ID 조회 (Resource Policy용)
data "aws_caller_identity" "us_east_1" {
  provider = aws.us_east_1
}

# 현재 AWS 계정 ID 조회 (Lambda, OpenSearch용)
data "aws_caller_identity" "current" {}

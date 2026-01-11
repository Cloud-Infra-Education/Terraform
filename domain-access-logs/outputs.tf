# CloudWatch Log Group ARN
output "cloudwatch_log_group_arn" {
  description = "CloudWatch Log Group ARN"
  value       = aws_cloudwatch_log_group.route53_query_logs.arn
}

# OpenSearch 도메인 엔드포인트
output "opensearch_endpoint" {
  description = "OpenSearch 도메인 엔드포인트"
  value       = aws_opensearch_domain.route53_logs.endpoint
}

# OpenSearch 대시보드 URL
output "opensearch_dashboard_url" {
  description = "OpenSearch 대시보드 URL"
  value       = aws_opensearch_domain.route53_logs.dashboard_endpoint
}

# Lambda 함수 ARN
output "lambda_function_arn" {
  description = "Lambda 함수 ARN"
  value       = aws_lambda_function.route53_log_processor.arn
}

# Lambda 함수 이름
output "lambda_function_name" {
  description = "Lambda 함수 이름"
  value       = aws_lambda_function.route53_log_processor.function_name
}

# Route53 Query Log ID
output "route53_query_log_id" {
  description = "Route53 Query Log ID"
  value       = aws_route53_query_log.main.id
}
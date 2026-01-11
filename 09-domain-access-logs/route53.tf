# Route53 Query Logging: Public Hosted Zone의 DNS 쿼리를 CloudWatch Logs로 전송
resource "aws_route53_query_log" "main" {
  depends_on = [aws_cloudwatch_log_resource_policy.route53_logs_policy]

  cloudwatch_log_group_arn = aws_cloudwatch_log_group.route53_query_logs.arn
  zone_id                  = var.route53_zone_id
}
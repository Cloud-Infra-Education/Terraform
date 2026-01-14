output "cloudfront_web_acl_arn" {
  description = "CloudFront(scope=CLOUDFRONT) WAFv2 WebACL ARN"
  value       = aws_wafv2_web_acl.cloudfront.arn
}

output "seoul_web_acl_arn" {
  description = "Seoul ALB(scope=REGIONAL) WAFv2 WebACL ARN"
  value       = aws_wafv2_web_acl.seoul.arn
}

output "oregon_web_acl_arn" {
  description = "Oregon ALB(scope=REGIONAL) WAFv2 WebACL ARN"
  value       = aws_wafv2_web_acl.oregon.arn
}


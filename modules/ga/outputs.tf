output "accelerator_arn" {
  description = "ARN of the Global Accelerator."
  value       = aws_globalaccelerator_accelerator.this.id
}

output "dns_name" {
  description = "GA DNS name (use this as Route53 alias target)."
  value       = aws_globalaccelerator_accelerator.this.dns_name
}

output "hosted_zone_id" {
  description = "GA Route53 hosted zone id (use with alias record)."
  value       = aws_globalaccelerator_accelerator.this.hosted_zone_id
}

output "listener_arn" {
  description = "ARN of the GA listener."
  value       = aws_globalaccelerator_listener.this.id
}

output "seoul_alb_arn" {
  description = "Resolved ALB ARN in ap-northeast-2."
  value       = data.aws_lb.seoul.arn
}

output "oregon_alb_arn" {
  description = "Resolved ALB ARN in us-west-2."
  value       = data.aws_lb.oregon.arn
}


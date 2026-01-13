# Database 모듈 outputs
output "proxy_endpoint" {
  value = module.database.proxy_endpoint
}

output "lambda_sg_id" {
  value = module.database.lambda_sg_id
}

output "db_instance_id" {
  value = module.database.db_instance_id
}

output "db_username" {
  value     = module.database.db_username
  sensitive = true
}

output "db_password" {
  value     = module.database.db_password
  sensitive = true
}

output "master_username" {
  value = module.database.master_username
}

# Lambda IAM 역할 outputs
output "video_processor_role_arn" {
  value = aws_iam_role.video_exec.arn
}

output "video_processor_role_name" {
  value = aws_iam_role.video_exec.name
}

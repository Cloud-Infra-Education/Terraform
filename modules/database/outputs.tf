output "proxy_endpoint" {
  value = aws_db_proxy.kor.endpoint
}

output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}

output "db_instance_id" {
  value = aws_rds_cluster_instance.kor_writer.id
}

# Secrets Manager의 사용자명 (proxy_admin)
output "db_username" {
  value = jsondecode(data.aws_secretsmanager_secret_version.kor_db.secret_string)["username"]
}

# Secrets Manager의 비밀번호
output "db_password" {
  value     = jsondecode(data.aws_secretsmanager_secret_version.kor_db.secret_string)["password"]
  sensitive = true
}

# DB 클러스터의 마스터 사용자명 (admin)
output "master_username" {
  value = var.db_username
}

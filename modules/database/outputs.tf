output "kor_db_cluster_endpoint" {
  value = aws_rds_cluster.kor.endpoint
}

output "usa_db_cluster_endpoint" {
  value = aws_rds_cluster.usa.endpoint
}

output "db_port" {
  value = aws_rds_cluster.kor.port
}

output "kor_db_security_group_id" {
  value = aws_security_group.db_kor.id
}

output "usa_db_security_group_id" {
  value = aws_security_group.db_usa.id
}

output "kor_cluster_id" {
  value = aws_rds_cluster.kor.id
}

output "usa_cluster_id" {
  value = aws_rds_cluster.usa.id
}

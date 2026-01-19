output "kor_cluster_id" {
  value = aws_rds_cluster.kor.id
}

output "kor_cluster_endpoint" {
  value = aws_rds_cluster.kor.endpoint
}

output "kor_cluster_reader_endpoint" {
  value = aws_rds_cluster.kor.reader_endpoint
}

output "kor_db_security_group_id" {
  value = aws_security_group.db_kor.id
}

output "usa_cluster_id" {
  value = aws_rds_cluster.usa.id
}

output "usa_cluster_endpoint" {
  value = aws_rds_cluster.usa.endpoint
}

output "usa_cluster_reader_endpoint" {
  value = aws_rds_cluster.usa.reader_endpoint
}

output "usa_db_security_group_id" {
  value = aws_security_group.db_usa.id
}

output "db_instance_id" {
  value = aws_rds_cluster_instance.kor_writer.id
}
output "kor_rds_proxy_endpoint" {
  value       = aws_db_proxy.kor.endpoint
}

output "usa_rds_proxy_endpoint" {
  value       = aws_db_proxy.usa.endpoint
}

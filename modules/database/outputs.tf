output "kor_db_proxy_endpoint" {
  description = "Korea RDS Proxy endpoint"
  value       = aws_db_proxy.kor.endpoint
}

output "usa_db_proxy_endpoint" {
  description = "USA RDS Proxy endpoint"
  value       = aws_db_proxy.usa.endpoint
}

output "kor_db_cluster_endpoint" {
  description = "Korea RDS Cluster endpoint"
  value       = aws_rds_cluster.kor.endpoint
}

output "usa_db_cluster_endpoint" {
  description = "USA RDS Cluster endpoint"
  value       = aws_rds_cluster.usa.endpoint
}

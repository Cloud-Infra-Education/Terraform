output "kor_db_proxy_endpoint" {
  description = "Korea RDS Proxy endpoint"
  value       = module.database.kor_db_proxy_endpoint
}

output "usa_db_proxy_endpoint" {
  description = "USA RDS Proxy endpoint"
  value       = module.database.usa_db_proxy_endpoint
}

output "kor_db_cluster_endpoint" {
  description = "Korea RDS Cluster endpoint"
  value       = module.database.kor_db_cluster_endpoint
}

output "usa_db_cluster_endpoint" {
  description = "USA RDS Cluster endpoint"
  value       = module.database.usa_db_cluster_endpoint
}

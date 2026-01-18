output "kor_cluster_id" {
#  value = aws_rds_cluster.kor.id
  value = module.database.kor_cluster_id
}

output "kor_cluster_endpoint" {
#  value = aws_rds_cluster.kor.endpoint
  value = module.database.kor_cluster_endpoint
}

output "kor_cluster_reader_endpoint" {
#  value = aws_rds_cluster.kor.reader_endpoint
  value = module.database.kor_cluster_reader_endpoint
}

output "kor_db_security_group_id" {
#  value = aws_security_group.db_kor.id
  value = module.database.kor_db_security_group_id
}

output "usa_cluster_id" {
#  value = aws_rds_cluster.usa.id
  value = module.database.usa_cluster_id
}

output "usa_cluster_endpoint" {
#  value = aws_rds_cluster.usa.endpoint
  value = module.database.usa_cluster_endpoint
}

output "usa_cluster_reader_endpoint" {
#  value = aws_rds_cluster.usa.reader_endpoint
  value = module.database.usa_cluster_reader_endpoint
}

output "usa_db_security_group_id" {
#  value = aws_security_group.db_usa.id
  value = module.database.usa_db_security_group_id
}


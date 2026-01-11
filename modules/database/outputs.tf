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

output "global_cluster_id" {
  value = aws_rds_global_cluster.global.id
}

# Primary (서울)
output "primary_cluster_id" {
  value = aws_rds_cluster.kor.id
}

output "primary_cluster_endpoint" {
  value = aws_rds_cluster.kor.endpoint
}

output "primary_region" {
  value = "ap-northeast-2"
}

# Secondary (오레곤)
output "secondary_clusters" {
  value = {
    "us-west-2" = {
      cluster_id = aws_rds_cluster.usa.id
      endpoint   = aws_rds_cluster.usa.endpoint
    }
  }
}


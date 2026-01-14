/*
output "namespace" {
  value = kubernetes_namespace_v1.monitoring.metadata[0].name
}
*/

output "s3_buckets_seoul" {
  description = "S3 bucket names used by LGTM components in Seoul."
  value = {
    loki               = module.s3_loki.bucket_name
    tempo              = module.s3_tempo.bucket_name
    mimir_blocks        = module.s3_mimir_blocks.bucket_name
    mimir_alertmanager  = module.s3_mimir_alertmanager.bucket_name
    mimir_ruler         = module.s3_mimir_ruler.bucket_name
  }
}

output "irsa_role_arns_seoul" {
  description = "IRSA role ARNs for LGTM components in Seoul."
  value = {
    loki  = aws_iam_role.loki_seoul.arn
    mimir = aws_iam_role.mimir_seoul.arn
    tempo = aws_iam_role.tempo_seoul.arn
  }
}

output "grafana_admin_password_seoul" {
  description = "Grafana admin password for grafana-seoul (sensitive)."
  value       = random_password.grafana_admin.result
  sensitive   = true
}


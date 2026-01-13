output "s3_buckets_seoul" {
  description = "S3 bucket names used by LGTM components in Seoul."
  value = {
    loki  = module.s3_loki.bucket_name
    tempo = module.s3_tempo.bucket_name
  }
}

output "amp_workspace_seoul" {
  description = "AMP workspace info (Seoul)."
  value = {
    id     = aws_prometheus_workspace.seoul.id
    arn    = aws_prometheus_workspace.seoul.arn
    alias  = aws_prometheus_workspace.seoul.alias
    region = var.region
  }
}

output "amp_endpoints_seoul" {
  description = "In-cluster AMP endpoints used by Alloy/Grafana (Seoul)."
  value = {
    query_base_url           = local.amp_query_base_url
    remote_write_url         = local.amp_remote_write_url
    query_proxy_svc          = kubernetes_service_v1.amp_query_sigv4_proxy_seoul.metadata[0].name
    remote_write_proxy_svc   = kubernetes_service_v1.amp_remote_write_sigv4_proxy_seoul.metadata[0].name
  }
}

output "irsa_role_arns_seoul" {
  description = "IRSA role ARNs for app-monitoring components in Seoul."
  value = {
    loki             = aws_iam_role.loki_seoul.arn
    tempo            = aws_iam_role.tempo_seoul.arn
    amp_remote_write = aws_iam_role.amp_remote_write_seoul.arn
    amp_query        = aws_iam_role.amp_query_seoul.arn
  }
}

output "grafana_admin_password_seoul" {
  description = "Grafana admin password for grafana-seoul (sensitive)."
  value       = coalesce(var.grafana_admin_password, random_password.grafana_admin.result)
  sensitive   = true
}


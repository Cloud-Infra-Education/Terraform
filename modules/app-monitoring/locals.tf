locals {
  suffix = "seoul"

  sanitized_prefix = lower(replace(var.name_prefix, "/[^a-z0-9-/]", "-"))

  # -----------------
  # Storage backends
  # -----------------
  bucket_names = {
    loki  = "${local.sanitized_prefix}-loki-${local.suffix}-${data.aws_caller_identity.this.account_id}"
    tempo = "${local.sanitized_prefix}-tempo-${local.suffix}-${data.aws_caller_identity.this.account_id}"
  }

  # -----------------
  # AMP (Amazon Managed Prometheus)
  # -----------------
  amp_workspace_alias = coalesce(var.amp_workspace_alias_seoul, "${local.sanitized_prefix}-amp-${local.suffix}")
  amp_host            = "aps-workspaces.${var.region}.amazonaws.com"

  # -----------------
  # K8s identities
  # -----------------
  service_accounts = {
    loki             = "loki-${local.suffix}"
    tempo            = "tempo-${local.suffix}"
    grafana          = "grafana-${local.suffix}"
    alloy            = "alloy-${local.suffix}"
    amp_remote_write = var.amp_remote_write_sa_name
    amp_query        = var.amp_query_sa_name
  }

  releases = {
    loki    = "loki-${local.suffix}"
    tempo   = "tempo-${local.suffix}"
    grafana = "grafana-${local.suffix}"
    alloy   = "alloy-${local.suffix}"
  }

  # Predictable in-cluster service addresses by using fullnameOverride.
  loki_gateway_url         = "http://loki-${local.suffix}-gateway.${var.namespace}.svc.cluster.local"
  tempo_otlp_grpc_endpoint = "tempo-${local.suffix}-distributor.${var.namespace}.svc.cluster.local:4317"

  # AMP SigV4 proxy endpoints (in-cluster)
  amp_query_base_url = "http://${var.amp_query_proxy_service_name}.${var.namespace}.svc.cluster.local:${var.amp_sigv4_proxy_port}/workspaces/${aws_prometheus_workspace.seoul.id}"
  amp_remote_write_url = "http://${var.amp_remote_write_proxy_service_name}.${var.namespace}.svc.cluster.local:${var.amp_sigv4_proxy_port}/workspaces/${aws_prometheus_workspace.seoul.id}/api/v1/remote_write"
}


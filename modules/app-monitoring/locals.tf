locals {
  suffix = "seoul"

  sanitized_prefix = lower(replace(var.name_prefix, "/[^a-z0-9-/]", "-"))

  bucket_names = {
    loki               = "${local.sanitized_prefix}-loki-${local.suffix}-${data.aws_caller_identity.this.account_id}"
    tempo              = "${local.sanitized_prefix}-tempo-${local.suffix}-${data.aws_caller_identity.this.account_id}"
    mimir_blocks        = "${local.sanitized_prefix}-mimir-blocks-${local.suffix}-${data.aws_caller_identity.this.account_id}"
    mimir_alertmanager  = "${local.sanitized_prefix}-mimir-alertmanager-${local.suffix}-${data.aws_caller_identity.this.account_id}"
    mimir_ruler         = "${local.sanitized_prefix}-mimir-ruler-${local.suffix}-${data.aws_caller_identity.this.account_id}"
  }

  service_accounts = {
    loki    = "loki-${local.suffix}"
    mimir   = "mimir-${local.suffix}"
    tempo   = "tempo-${local.suffix}"
    grafana = "grafana-${local.suffix}"
    alloy   = "alloy-${local.suffix}"
  }

  releases = {
    loki    = "loki-${local.suffix}"
    mimir   = "mimir-${local.suffix}"
    tempo   = "tempo-${local.suffix}"
    grafana = "grafana-${local.suffix}"
    alloy   = "alloy-${local.suffix}"
  }

  # Predictable in-cluster service addresses by using fullnameOverride.
  loki_gateway_url        = "http://loki-${local.suffix}-gateway.${var.namespace}.svc.cluster.local"
  mimir_nginx_url         = "http://mimir-${local.suffix}-nginx.${var.namespace}.svc.cluster.local"
  tempo_otlp_grpc_endpoint = "tempo-${local.suffix}-distributor.${var.namespace}.svc.cluster.local:4317"
}


variable "eks_cluster_name" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-northeast-2"
}

variable "name_prefix" {
  type = string
}

variable "namespace" {
  type    = string
  default = "app-monitoring-seoul"
}

variable "eks_seoul_oidc_provider_arn" {
  type        = string
  default     = null
}

# ==============================
# Loki
# ==============================

variable "loki_wal_storageclass_name" {
  type    = string
  default = "loki-wal-gp3-seoul"
}

variable "loki_wal_size" {
  type    = string
  default = "20Gi"
}

variable "loki_chart_version" {
  type    = string
  default = "6.49.0"
}

# ==============================
# Tempo
# ==============================

variable "tempo_chart_version" {
  type    = string
  default = "1.60.0"
}

# ==============================
# Grafana
# ==============================

variable "grafana_chart_version" {
  type    = string
  default = "8.6.0"
}

# If set, overrides the generated random password.
variable "grafana_admin_password" {
  type        = string
  default     = null
  sensitive   = true
  description = "(Optional) Grafana admin password override. If null, a random password will be generated."
}

# ==============================
# Alloy
# ==============================

variable "alloy_chart_version" {
  type    = string
  default = "0.7.0"
}

variable "tenant_org_id" {
  type    = string
  default = "monitoring"
}

# ==============================
# AMP (Amazon Managed Prometheus)
# ==============================

variable "amp_workspace_alias_seoul" {
  type        = string
  default     = null
  description = "(Optional) Alias for the AMP workspace in Seoul."
}

variable "amp_remote_write_sa_name" {
  type    = string
  default = "amp-remote-write-sa"
}

variable "amp_query_sa_name" {
  type    = string
  default = "amp-query-proxy-sa"
}

variable "amp_remote_write_proxy_service_name" {
  type    = string
  default = "amp-remote-write-proxy"
}

variable "amp_query_proxy_service_name" {
  type    = string
  default = "amp-sigv4-proxy"
}

variable "amp_sigv4_proxy_image" {
  type    = string
  default = "public.ecr.aws/aws-observability/aws-sigv4-proxy:1.0"
}

variable "amp_sigv4_proxy_port" {
  type    = number
  default = 8005
}


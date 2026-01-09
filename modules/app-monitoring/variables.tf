variable "eks_cluster_name" {
  type        = string
}

variable "region" {
  type        = string
  default     = "ap-northeast-2"
}

variable "name_prefix" {
  type        = string
}

variable "namespace" {
  type        = string
  default     = "app-monitoring-seoul"
}

variable "loki_wal_storageclass_name" {
  type        = string
  default     = "loki-wal-gp3-seoul"
}

variable "loki_wal_size" {
  type        = string
  default     = "20Gi"
}

variable "loki_chart_version" {
  type = string
  default = "6.49.0"
}

variable "mimir_chart_version" {
  type        = string
  default     = "5.8.0"
}

variable "mimir_storageclass_name" {
  type        = string
  default     = "mimir-gp3-seoul"
}

variable "tempo_chart_version" {
  type        = string
  default     = "1.60.0"
}

variable "grafana_chart_version" {
  type        = string
  default     = "8.6.0"
}

variable "alloy_chart_version" {
  type        = string
  default     = "0.7.0"
}

variable "tenant_org_id" {
  type        = string
  default     = "chan"
}

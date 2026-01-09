variable "eks_cluster_name" {
  description = "Existing EKS cluster name (Seoul)."
  type        = string
}

variable "region" {
  description = "AWS region for the monitoring stack (Seoul)."
  type        = string
  default     = "ap-northeast-2"
}

variable "name_prefix" {
  description = "Prefix used for resource naming."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to install LGTM + Alloy into."
  type        = string
  default     = "app-monitoring-seoul"
}

variable "loki_wal_storageclass_name" {
  description = "EBS StorageClass name used by Loki WAL PVCs."
  type        = string
  default     = "loki-wal-gp3-seoul"
}

variable "loki_wal_size" {
  description = "Requested PVC size for Loki WAL."
  type        = string
  default     = "20Gi"
}

variable "loki_chart_version" {
  type = string
  default = "6.49.0"
}

variable "mimir_chart_version" {
  description = "Helm chart version for grafana/mimir-distributed. Pinned to a 5.x release to keep classic architecture defaults."
  type        = string
  default     = "5.8.0"
}

variable "mimir_storageclass_name" {
  description = "EBS StorageClass name used by Mimir PVCs."
  type        = string
  default     = "mimir-gp3-seoul"
}

variable "tempo_chart_version" {
  description = "Helm chart version for grafana/tempo-distributed."
  type        = string
  # Pin to a 1.x chart line (Tempo 2.x app versions).
  default     = "1.60.0"
}

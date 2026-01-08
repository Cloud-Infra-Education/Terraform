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

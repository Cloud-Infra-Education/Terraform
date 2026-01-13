data "aws_caller_identity" "this" {}

# Existing EKS cluster (read-only) via data sources
data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}

# Existing OIDC provider for IRSA (read-only)
data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

locals {
  # IRSA condition key requires issuer hostpath without the https:// prefix.
  oidc_issuer_hostpath = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")

  # Allow overriding OIDC provider ARN (e.g., when using cross-account/remote references).
  oidc_provider_arn = coalesce(var.eks_seoul_oidc_provider_arn, data.aws_iam_openid_connect_provider.this.arn)
}

resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}

# =====================
# Layer 1 - S3 buckets
# =====================

module "s3_loki" {
  source = "../s3"

  origin_bucket_name = local.bucket_names.loki
}

module "s3_tempo" {
  source = "../s3"

  origin_bucket_name = local.bucket_names.tempo
}


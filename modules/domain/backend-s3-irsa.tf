# Backend API S3 IRSA (IAM Roles for Service Accounts)
# S3 읽기 권한을 위한 IRSA 설정

# EKS 클러스터 정보 가져오기
data "aws_eks_cluster" "seoul" {
  provider = aws.seoul
  name     = var.eks_cluster_name
}

# OIDC Provider 정보 가져오기
data "aws_iam_openid_connect_provider" "seoul" {
  provider = aws.seoul
  url      = data.aws_eks_cluster.seoul.identity[0].oidc[0].issuer
}

locals {
  oidc_issuer_hostpath = replace(data.aws_eks_cluster.seoul.identity[0].oidc[0].issuer, "https://", "")
  backend_sa_subject   = "system:serviceaccount:formation-lap:backend-api-sa"
}

# Kubernetes Service Account
resource "kubernetes_service_account_v1" "backend_api_sa" {
  metadata {
    name      = "backend-api-sa"
    namespace = "formation-lap"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.backend_s3_seoul.arn
    }
  }
}

# IAM Trust Policy (IRSA)
data "aws_iam_policy_document" "backend_s3_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.seoul.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = [local.backend_sa_subject]
    }
  }
}

# IAM Role
resource "aws_iam_role" "backend_s3_seoul" {
  provider           = aws.seoul
  name               = "${var.our_team}-backend-api-s3-irsa"
  assume_role_policy = data.aws_iam_policy_document.backend_s3_trust.json
}

# IAM Policy (S3 읽기 권한)
data "aws_iam_policy_document" "backend_s3_policy" {
  statement {
    sid    = "BackendS3ReadOnly"
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:HeadObject"
    ]
    resources = [
      "arn:aws:s3:::${var.origin_bucket_name}",
      "arn:aws:s3:::${var.origin_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "backend_s3_seoul" {
  provider = aws.seoul
  name     = "${var.our_team}-backend-api-s3-readonly"
  policy   = data.aws_iam_policy_document.backend_s3_policy.json
}

# IAM Role Policy Attachment
resource "aws_iam_role_policy_attachment" "backend_s3_seoul" {
  provider   = aws.seoul
  role       = aws_iam_role.backend_s3_seoul.name
  policy_arn = aws_iam_policy.backend_s3_seoul.arn
}

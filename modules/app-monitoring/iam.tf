locals {
  sa_subjects = {
    loki  = "system:serviceaccount:${var.namespace}:${local.service_accounts.loki}"
    mimir = "system:serviceaccount:${var.namespace}:${local.service_accounts.mimir}"
    tempo = "system:serviceaccount:${var.namespace}:${local.service_accounts.tempo}"
  }
}

# -----------------
# Loki IRSA
# -----------------

data "aws_iam_policy_document" "loki_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = [local.sa_subjects.loki]
    }
  }
}

resource "aws_iam_role" "loki_seoul" {
  name               = "loki-irsa-seoul"
  assume_role_policy = data.aws_iam_policy_document.loki_trust.json
}

data "aws_iam_policy_document" "loki_s3" {
  statement {
    sid     = "LokiS3"
    effect  = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      module.s3_loki.bucket_arn,
      "${module.s3_loki.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "loki_s3_seoul" {
  name   = "loki-s3-seoul"
  policy = data.aws_iam_policy_document.loki_s3.json
}

resource "aws_iam_role_policy_attachment" "loki_s3_seoul" {
  role       = aws_iam_role.loki_seoul.name
  policy_arn = aws_iam_policy.loki_s3_seoul.arn
}

# -----------------
# Tempo IRSA
# -----------------

data "aws_iam_policy_document" "tempo_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = [local.sa_subjects.tempo]
    }
  }
}

resource "aws_iam_role" "tempo_seoul" {
  name               = "tempo-irsa-seoul"
  assume_role_policy = data.aws_iam_policy_document.tempo_trust.json
}

data "aws_iam_policy_document" "tempo_s3" {
  statement {
    sid     = "TempoPermissions"
    effect  = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DeleteObject",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging"
    ]
    resources = [
      module.s3_tempo.bucket_arn,
      "${module.s3_tempo.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "tempo_s3_seoul" {
  name   = "tempo-s3-seoul"
  policy = data.aws_iam_policy_document.tempo_s3.json
}

resource "aws_iam_role_policy_attachment" "tempo_s3_seoul" {
  role       = aws_iam_role.tempo_seoul.name
  policy_arn = aws_iam_policy.tempo_s3_seoul.arn
}

# -----------------
# Mimir IRSA
# -----------------

data "aws_iam_policy_document" "mimir_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.this.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = [local.sa_subjects.mimir]
    }
  }
}

resource "aws_iam_role" "mimir_seoul" {
  name               = "mimir-irsa-seoul"
  assume_role_policy = data.aws_iam_policy_document.mimir_trust.json
}

data "aws_iam_policy_document" "mimir_s3" {
  statement {
    sid     = "MimirS3"
    effect  = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads",
      "s3:ListMultipartUploadParts"
    ]
    resources = [
      module.s3_mimir_blocks.bucket_arn,
      "${module.s3_mimir_blocks.bucket_arn}/*",
      module.s3_mimir_alertmanager.bucket_arn,
      "${module.s3_mimir_alertmanager.bucket_arn}/*",
      module.s3_mimir_ruler.bucket_arn,
      "${module.s3_mimir_ruler.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "mimir_s3_seoul" {
  name   = "mimir-s3-seoul"
  policy = data.aws_iam_policy_document.mimir_s3.json
}

resource "aws_iam_role_policy_attachment" "mimir_s3_seoul" {
  role       = aws_iam_role.mimir_seoul.name
  policy_arn = aws_iam_policy.mimir_s3_seoul.arn
}


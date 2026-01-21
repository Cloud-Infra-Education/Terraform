locals {
  sa_subjects = {
    loki             = "system:serviceaccount:${var.namespace}:${local.service_accounts.loki}"
    tempo            = "system:serviceaccount:${var.namespace}:${local.service_accounts.tempo}"
    amp_remote_write = "system:serviceaccount:${var.namespace}:${local.service_accounts.amp_remote_write}"
    amp_query        = "system:serviceaccount:${var.namespace}:${local.service_accounts.amp_query}"
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
      identifiers = [local.oidc_provider_arn]
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
      "s3:ListMultipartUploadParts",
    ]
    resources = [
      module.s3_loki.bucket_arn,
      "${module.s3_loki.bucket_arn}/*",
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
      identifiers = [local.oidc_provider_arn]
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
      "s3:PutObjectTagging",
    ]
    resources = [
      module.s3_tempo.bucket_arn,
      "${module.s3_tempo.bucket_arn}/*",
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
# AMP IRSA (Remote write)
# -----------------

data "aws_iam_policy_document" "amp_remote_write_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = [local.sa_subjects.amp_remote_write]
    }
  }
}

resource "aws_iam_role" "amp_remote_write_seoul" {
  name               = "amp-remote-write-irsa-seoul"
  assume_role_policy = data.aws_iam_policy_document.amp_remote_write_trust.json
}

data "aws_iam_policy_document" "amp_remote_write" {
  statement {
    sid     = "AMPRemoteWrite"
    effect  = "Allow"
    actions = ["aps:RemoteWrite"]
    resources = [
      aws_prometheus_workspace.seoul.arn,
    ]
  }
}

resource "aws_iam_policy" "amp_remote_write_seoul" {
  name   = "amp-remote-write-seoul-${aws_prometheus_workspace.seoul.id}"
  policy = data.aws_iam_policy_document.amp_remote_write.json
}

resource "aws_iam_role_policy_attachment" "amp_remote_write_seoul" {
  role       = aws_iam_role.amp_remote_write_seoul.name
  policy_arn = aws_iam_policy.amp_remote_write_seoul.arn
}

# -----------------
# AMP IRSA (Query)
# -----------------

data "aws_iam_policy_document" "amp_query_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [local.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer_hostpath}:sub"
      values   = [local.sa_subjects.amp_query]
    }
  }
}

resource "aws_iam_role" "amp_query_seoul" {
  name               = "amp-query-irsa-seoul"
  assume_role_policy = data.aws_iam_policy_document.amp_query_trust.json
}

data "aws_iam_policy_document" "amp_query" {
  statement {
    sid    = "AMPQuery"
    effect = "Allow"
    actions = [
      "aps:QueryMetrics",
      "aps:GetSeries",
      "aps:GetLabels",
      "aps:GetMetricMetadata",
    ]
    resources = [
      aws_prometheus_workspace.seoul.arn,
    ]
  }
}

resource "aws_iam_policy" "amp_query_seoul" {
  name   = "amp-query-seoul-${aws_prometheus_workspace.seoul.id}"
  policy = data.aws_iam_policy_document.amp_query.json
}

resource "aws_iam_role_policy_attachment" "amp_query_seoul" {
  role       = aws_iam_role.amp_query_seoul.name
  policy_arn = aws_iam_policy.amp_query_seoul.arn
}


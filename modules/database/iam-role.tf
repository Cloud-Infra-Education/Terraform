# RDS Proxy는 Secrets Manager에 대한 접근 권한이 있어야 한다람쥐
data "aws_iam_policy_document" "rds_proxy_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# ============= Seoul Region ================
resource "aws_iam_role" "kor_rds_proxy" {
  provider           = aws.seoul
  name               = "y2om-${var.our_team}-KOR-RDS-Proxy-Role"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_assume_role.json
}

resource "aws_iam_role_policy" "kor_rds_proxy" {
  provider = aws.seoul
  name     = "y2om-${var.our_team}-KOR-RDS-Proxy-Secrets-Policy"
  role     = aws_iam_role.kor_rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = data.aws_secretsmanager_secret.kor_db.arn
      }
    ]
  })
}

# ============= Oregon Region ================
resource "aws_iam_role" "usa_rds_proxy" {
  provider           = aws.oregon
  name               = "y2om-${var.our_team}-USA-RDS-Proxy-Role"
  assume_role_policy = data.aws_iam_policy_document.rds_proxy_assume_role.json
}

resource "aws_iam_role_policy" "usa_rds_proxy" {
  provider = aws.oregon
  name     = "y2om-${var.our_team}-USA-RDS-Proxy-Secrets-Policy"
  role     = aws_iam_role.usa_rds_proxy.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
        Resource = data.aws_secretsmanager_secret.usa_db.arn
      }
    ]
  })
}


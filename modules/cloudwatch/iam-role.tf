resource "aws_iam_role" "alert_exec" {
  name = "${var.our_team}-alert-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "alert_secrets_policy" {
  name = "${var.our_team}-alert-secrets-policy"
  role = aws_iam_role.alert_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["secretsmanager:GetSecretValue"]
      Resource = [data.aws_secretsmanager_secret.slack_webhook.arn]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "alert_vpc" {
  role       = aws_iam_role.alert_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "alert_basic" {
  role       = aws_iam_role.alert_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


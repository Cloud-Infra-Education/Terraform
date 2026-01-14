data "aws_secretsmanager_secret" "slack_webhook" {
  provider = aws.seoul
  name     = var.slack_secret_name 
}

data "aws_secretsmanager_secret_version" "slack_webhook_val" {
  provider  = aws.seoul
  secret_id = data.aws_secretsmanager_secret.slack_webhook.id
}

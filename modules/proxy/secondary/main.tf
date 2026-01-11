resource "aws_db_proxy" "this" {
  name          = "${var.region}-secondary-rds-proxy"
  engine_family = "MYSQL"
  role_arn     = var.iam_role_arn

  vpc_subnet_ids         = var.subnet_ids
  vpc_security_group_ids = [var.security_group_id]

  auth {
    auth_scheme = "SECRETS"
    secret_arn = var.secret_arn
    iam_auth   = "DISABLED"
  }
}

resource "aws_db_proxy_default_target_group" "this" {
  db_proxy_name = aws_db_proxy.this.name
}

resource "aws_db_proxy_target" "this" {
  db_proxy_name         = aws_db_proxy.this.name
  target_group_name     = aws_db_proxy_default_target_group.this.name
  db_cluster_identifier = var.cluster_id
}


# =========== Seoul Region =============
resource "aws_db_proxy" "kor" {
  provider               = aws.seoul

  name                   = "${var.our_team}-kor-rds-proxy"
  engine_family          = "MYSQL"
  role_arn               = aws_iam_role.kor_rds_proxy.arn
  vpc_subnet_ids         = var.kor_private_db_subnet_ids
  vpc_security_group_ids = [aws_security_group.proxy_kor.id]

  require_tls            = var.proxy_require_tls
  idle_client_timeout    = var.proxy_idle_client_timeout
  debug_logging          = var.proxy_debug_logging

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = data.aws_secretsmanager_secret.kor_db.arn
    iam_auth    = "DISABLED"
  }

  depends_on = [data.aws_secretsmanager_secret_version.kor_db]
}

resource "aws_db_proxy_default_target_group" "kor" {
  provider      = aws.seoul

  db_proxy_name = aws_db_proxy.kor.name

  connection_pool_config {
    max_connections_percent      = var.proxy_max_connections_percent
    max_idle_connections_percent = var.proxy_max_idle_connections_percent
    connection_borrow_timeout    = var.proxy_connection_borrow_timeout
  }
}

resource "aws_db_proxy_target" "kor_cluster" {
  provider              = aws.seoul

  db_proxy_name         = aws_db_proxy.kor.name
  target_group_name     = aws_db_proxy_default_target_group.kor.name
  db_cluster_identifier = aws_rds_cluster.kor.id
}

# =========== Oregon Region =============
resource "aws_db_proxy" "usa" {
  provider               = aws.oregon

  name                   = "${var.our_team}-usa-rds-proxy"
  engine_family          = "MYSQL"
  role_arn               = aws_iam_role.usa_rds_proxy.arn
  vpc_subnet_ids         = var.usa_private_db_subnet_ids
  vpc_security_group_ids = [aws_security_group.proxy_usa.id]

  require_tls            = var.proxy_require_tls
  idle_client_timeout    = var.proxy_idle_client_timeout
  debug_logging          = var.proxy_debug_logging

  auth {
    auth_scheme = "SECRETS"
    secret_arn  = data.aws_secretsmanager_secret.usa_db.arn
    iam_auth    = "DISABLED"
  }

  depends_on = [data.aws_secretsmanager_secret_version.usa_db]
}

resource "aws_db_proxy_default_target_group" "usa" {
  provider      = aws.oregon

  db_proxy_name = aws_db_proxy.usa.name

  connection_pool_config {
    max_connections_percent      = var.proxy_max_connections_percent
    max_idle_connections_percent = var.proxy_max_idle_connections_percent
    connection_borrow_timeout    = var.proxy_connection_borrow_timeout
  }
}

resource "aws_db_proxy_target" "usa_cluster" {
  provider              = aws.oregon

  db_proxy_name         = aws_db_proxy.usa.name
  target_group_name     = aws_db_proxy_default_target_group.usa.name
  db_cluster_identifier = aws_rds_cluster.usa.id
}

resource "aws_db_proxy_endpoint" "usa_ro" {
  provider               = aws.oregon

  db_proxy_name          = aws_db_proxy.usa.name
  db_proxy_endpoint_name = "${var.our_team}-usa-proxy-ro"
  vpc_subnet_ids         = var.usa_private_db_subnet_ids
  vpc_security_group_ids = [aws_security_group.proxy_usa.id] # 기존 프록시 SG 그대로 사용

  # 핵심: 현재 오리건은 Secondary이므로 이 옵션이 있어야 리더 인스턴스에 접속 가능합니다.
  target_role            = "READ_ONLY"
}


resource "aws_secretsmanager_secret" "source_db" {
  name = "dms/source-db"
}

resource "aws_secretsmanager_secret_version" "source_db" {
  secret_id = aws_secretsmanager_secret.source_db.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}


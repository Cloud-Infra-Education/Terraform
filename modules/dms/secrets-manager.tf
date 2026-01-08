resource "aws_secretsmanager_secret" "onprem_source_db" {
  name = "${var.our_team}-dms/onprem-source-db"
}

resource "aws_secretsmanager_secret_version" "onprem_source_db" {
  secret_id = aws_secretsmanager_secret.onprem_source_db.id
  secret_string = jsonencode({
    username = var.onprem_db_username
    password = var.onprem_db_password
  })
}


resource "aws_secretsmanager_secret" "source_db" {
  name = "${var.our_team}-dms/source-db"
}

resource "aws_secretsmanager_secret_version" "source_db" {
  secret_id = aws_secretsmanager_secret.source_db.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}


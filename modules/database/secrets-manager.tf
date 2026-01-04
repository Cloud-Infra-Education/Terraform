resource "aws_secretsmanager_secret" "kor_db" {
  provider = aws.seoul
  name     = "${var.our_team}-KOR-DB-Credentials-1"
}

resource "aws_secretsmanager_secret_version" "kor_db" {
  provider      = aws.seoul
  secret_id     = aws_secretsmanager_secret.kor_db.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

resource "aws_secretsmanager_secret" "usa_db" {
  provider = aws.oregon
  name     = "${var.our_team}-KOR-DB-Credentials-2"
}

resource "aws_secretsmanager_secret_version" "usa_db" {
  provider      = aws.oregon
  secret_id     = aws_secretsmanager_secret.usa_db.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}


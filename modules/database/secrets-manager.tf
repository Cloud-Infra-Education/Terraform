data "aws_secretsmanager_secret" "kor_db" {
  provider = aws.seoul
  name     = "${var.our_team}/db/dev/credentials"
}

data "aws_secretsmanager_secret_version" "kor_db" {
  provider  = aws.seoul
  secret_id = data.aws_secretsmanager_secret.kor_db.id
}

data "aws_secretsmanager_secret" "usa_db" {
  provider = aws.oregon
  name     = "${var.our_team}/db/dev/credentials"
}

data "aws_secretsmanager_secret_version" "usa_db" {
  provider  = aws.oregon
  secret_id = data.aws_secretsmanager_secret.usa_db.id
}


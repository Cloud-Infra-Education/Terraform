# =========================
# MySQL providers (모듈 내부 선언)
# =========================
terraform {
  required_providers {
    mysql = {
      source  = "petoju/mysql"
      version = "3.0.88"
    }
  }
}

provider "mysql" {
  alias    = "kor"
  endpoint = aws_rds_cluster.kor.endpoint
  username = var.db_username
  password = var.db_password

}

provider "mysql" {
  alias    = "usa"
  endpoint = aws_rds_cluster.usa.endpoint
  username = var.db_username
  password = var.db_password

}

resource "mysql_user" "dms_user_kor" {
  depends_on = [
    aws_rds_cluster.kor,
    aws_db_subnet_group.kor,
    aws_security_group.proxy_kor
  ]

  provider = mysql.kor
  user     = var.dms_db_username
  host     = "%"
  plaintext_password = var.dms_db_password
}

resource "mysql_grant" "dms_grant_kor" {
  depends_on = [
    aws_rds_cluster.kor,
    aws_db_subnet_group.kor,
    aws_security_group.proxy_kor
  ]

  provider   = mysql.kor
  user       = mysql_user.dms_user_kor.user
  host       = mysql_user.dms_user_kor.host
  database   = "*"
  privileges = ["SELECT", "REPLICATION SLAVE"]
}

resource "mysql_user" "dms_user_usa" {
  depends_on = [
    aws_rds_cluster.usa,
    aws_db_subnet_group.usa,
    aws_security_group.proxy_usa
  ]

  provider = mysql.usa
  user     = var.dms_db_username
  host     = "%"
  plaintext_password = var.dms_db_password
}

resource "mysql_grant" "dms_grant_usa" {
  depends_on = [
    aws_rds_cluster.usa,
    aws_db_subnet_group.usa,
    aws_security_group.proxy_usa
  ]

  provider   = mysql.usa
  user       = mysql_user.dms_user_usa.user
  host       = mysql_user.dms_user_usa.host
  database   = "*"
  privileges = ["SELECT", "REPLICATION SLAVE"]
}

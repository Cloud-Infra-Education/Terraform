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
  endpoint = var.kor_db_endpoint
  username = var.dms_db_username
  password = var.dms_db_password

}

provider "mysql" {
  alias    = "usa"
  endpoint = var.usa_db_endpoint
  username = var.dms_db_username
  password = var.dms_db_password

}

# =========================
# DMS용 사용자 생성
# =========================
resource "mysql_user" "dms_user_kor" {
  provider = mysql.kor
  user     = var.dms_db_username
  host     = "%"
  plaintext_password = var.dms_db_password
}

resource "mysql_grant" "dms_grant_kor" {
  provider   = mysql.kor
  user       = mysql_user.dms_user_kor.user
  host       = mysql_user.dms_user_kor.host
  database   = "*"
  privileges = ["SELECT", "REPLICATION SLAVE"]
}

resource "mysql_user" "dms_user_usa" {
  provider = mysql.usa
  user     = var.dms_db_username
  host     = "%"
  plaintext_password = var.dms_db_password
}

resource "mysql_grant" "dms_grant_usa" {
  provider   = mysql.usa
  user       = mysql_user.dms_user_usa.user
  host       = mysql_user.dms_user_usa.host
  database   = "*"
  privileges = ["SELECT", "REPLICATION SLAVE"]
}


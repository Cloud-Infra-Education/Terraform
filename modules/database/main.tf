resource "aws_db_subnet_group" "kor" {
  provider    = aws.seoul
  name        = "kor-db-subnet-group"
  subnet_ids  = var.kor_private_db_subnet_ids
}

resource "aws_db_subnet_group" "usa" {
  provider    = aws.oregon
  name        = "usa-db-subnet-group"
  subnet_ids  = var.usa_private_db_subnet_ids
}

resource "aws_rds_global_cluster" "global" {
# maxjagger  global_cluster_identifier = "global-aurora-mysql"
  global_cluster_identifier = "chan-global-aurora-mysql"
  engine                    = "aurora-mysql"

  storage_encrypted         = true
  deletion_protection       = false

  lifecycle {
    ignore_changes = [engine_version]
  }
}

resource "aws_rds_cluster" "kor" {
  provider = aws.seoul

#  cluster_identifier = "kor-aurora-mysql"
  cluster_identifier = "chan-kor-aurora-mysql"
  engine             = "aurora-mysql"

  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.kor.name
  vpc_security_group_ids = [aws_security_group.db_kor.id]

  storage_encrypted         = true
  kms_key_id                = aws_kms_key.aurora_seoul.arn
  global_cluster_identifier = aws_rds_global_cluster.global.id
  skip_final_snapshot = true

  lifecycle {
    ignore_changes = [engine_version]
  }
}

resource "aws_rds_cluster_instance" "kor_writer" {
  provider = aws.seoul

  identifier         = "kor-writer"
  cluster_identifier = aws_rds_cluster.kor.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.kor.engine

  availability_zone = "ap-northeast-2a"
  promotion_tier     = 0
}

resource "aws_rds_cluster_instance" "kor_reader" {
  provider = aws.seoul

  identifier         = "kor-reader"
  cluster_identifier = aws_rds_cluster.kor.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.kor.engine

  availability_zone = "ap-northeast-2b"
  promotion_tier     = 1
}


resource "aws_rds_cluster" "usa" {
  depends_on = [aws_rds_cluster.kor]
  provider = aws.oregon

#  cluster_identifier = "usa-aurora-mysql"
  cluster_identifier = "chan-usa-aurora-mysql"
  engine             = "aurora-mysql" 

# master_username = var.db_username
# master_password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.usa.name
  vpc_security_group_ids = [aws_security_group.db_usa.id]

  storage_encrypted         = true
  kms_key_id                = aws_kms_key.aurora_oregon.arn
  global_cluster_identifier = aws_rds_global_cluster.global.id
  skip_final_snapshot = true

  lifecycle {
    ignore_changes = [engine_version]
  }
}

resource "aws_rds_cluster_instance" "usa_reader1" {
  depends_on = [aws_rds_cluster.kor]
  provider = aws.oregon

  identifier         = "usa-reader1"
  cluster_identifier = aws_rds_cluster.usa.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.usa.engine

  availability_zone = "us-west-2a"
  promotion_tier     = 2
}

resource "aws_rds_cluster_instance" "usa_reader2" {
  depends_on = [aws_rds_cluster.kor]
  provider = aws.oregon

  identifier         = "usa-reader2"
  cluster_identifier = aws_rds_cluster.usa.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.usa.engine

  availability_zone = "us-west-2b"
  promotion_tier     = 3
}


resource "aws_rds_cluster" "kor" {
  provider = aws.seoul

  cluster_identifier = "kor-aurora-mysql"
  engine             = "aurora-mysql"

  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.kor.name
  vpc_security_group_ids = [aws_security_group.db_kor.id]

  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "kor_writer" {
  provider = aws.seoul

  identifier         = "kor-writer"
  cluster_identifier = aws_rds_cluster.kor.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.kor.engine
}

resource "aws_rds_cluster_instance" "kor_reader" {
  provider = aws.seoul

  identifier         = "kor-reader"
  cluster_identifier = aws_rds_cluster.kor.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.kor.engine
}


resource "aws_rds_cluster" "usa" {
  provider = aws.oregon

  cluster_identifier = "usa-aurora-mysql"
  engine             = "aurora-mysql"

  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.usa.name
  vpc_security_group_ids = [aws_security_group.db_usa.id]

  skip_final_snapshot = true
}

resource "aws_rds_cluster_instance" "usa_reader1" {
  provider = aws.oregon

  identifier         = "usa-reader-1"
  cluster_identifier = aws_rds_cluster.usa.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.usa.engine
}

resource "aws_rds_cluster_instance" "usa_reader2" {
  provider = aws.oregon

  identifier         = "usa-reader-2"
  cluster_identifier = aws_rds_cluster.usa.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.usa.engine
}


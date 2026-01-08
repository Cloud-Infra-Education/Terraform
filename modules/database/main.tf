resource "aws_db_subnet_group" "kor" {
  provider    = aws.seoul
  name        = "kor1-db-subnet-group" # 중복 회피
  subnet_ids  = var.kor_private_db_subnet_ids
}

resource "aws_db_subnet_group" "usa" {
  provider    = aws.oregon
  name        = "usa1-db-subnet-group" # 중복 회피 
  subnet_ids  = var.usa_private_db_subnet_ids
}

#############################
# Korea Aurora Cluster
#############################
resource "aws_rds_cluster" "kor" {
  provider = aws.seoul

  cluster_identifier = "kor1-aurora-mysql"
  engine             = "aurora-mysql"

  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.kor.name
  vpc_security_group_ids = [aws_security_group.db_kor.id]

  storage_encrypted    = true
  skip_final_snapshot  = true
}

resource "aws_rds_cluster_instance" "kor_writer" {
  provider = aws.seoul

  identifier         = "kor1-writer"
  cluster_identifier = aws_rds_cluster.kor.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.kor.engine
  promotion_tier     = 0
}

resource "aws_rds_cluster_instance" "kor_reader" {
  provider = aws.seoul

  identifier         = "kor1-reader"
  cluster_identifier = aws_rds_cluster.kor.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.kor.engine
  promotion_tier     = 1
}

#############################
# USA Aurora Cluster
#############################
resource "aws_rds_cluster" "usa" {
  provider = aws.oregon

  cluster_identifier = "usa1-aurora-mysql"
  engine             = "aurora-mysql"

  master_username = var.db_username
  master_password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.usa.name
  vpc_security_group_ids = [aws_security_group.db_usa.id]

  storage_encrypted    = true
  skip_final_snapshot  = true
}

resource "aws_rds_cluster_instance" "usa_writer" {
  provider = aws.oregon

  identifier         = "usa1-writer"
  cluster_identifier = aws_rds_cluster.usa.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.usa.engine

  promotion_tier = 0
}

resource "aws_rds_cluster_instance" "usa_reader1" {
  provider = aws.oregon

  identifier         = "usa1-reader1"
  cluster_identifier = aws_rds_cluster.usa.id
  instance_class     = "db.t4g.medium"
  engine             = aws_rds_cluster.usa.engine

  promotion_tier = 1
}

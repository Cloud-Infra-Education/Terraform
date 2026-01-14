# ============= Seoul Region DB Cluster =============
resource "aws_security_group" "db_kor" {
  provider    = aws.seoul
  name        = "SecurityGroup-DB-Cluster-Seoul"
  description = "KOR Aurora MySQL access"
  vpc_id      = var.kor_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----- RDS Proxy ----> DB Cluster 
resource "aws_security_group_rule" "kor_proxy_to_db" {
  provider                 = aws.seoul
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_kor.id
  source_security_group_id = aws_security_group.proxy_kor.id
}

# ============= Seoul Region RDS Proxy =============
resource "aws_security_group" "proxy_kor" {
  provider    = aws.seoul
  name        = "SecurityGroup-RDSproxy-Seoul"
  vpc_id      = var.kor_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----- EKS Workers ----> Proxy
resource "aws_security_group_rule" "kor_eks_to_proxy" {
  count                    = var.seoul_eks_workers_sg_id == null ? 0 : 1
  
  provider                 = aws.seoul
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.proxy_kor.id
  source_security_group_id = var.seoul_eks_workers_sg_id
}

# ============= Seoul Region Lambda_sg =============
resource "aws_security_group" "lambda_sg" {
  provider    = aws.seoul
  name        = "SecurityGroup-Lambda-Common"
  description = "Security group for video processing Lambda"
  vpc_id      = var.kor_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----- Lambda SG ----> RDS Proxy
resource "aws_security_group_rule" "kor_lambda_to_proxy" {
  provider                 = aws.seoul
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.proxy_kor.id
  source_security_group_id = aws_security_group.lambda_sg.id
}

# ----- Lambda SG ----> RDS Cluster (마스터 사용자로 직접 연결 시 필요)
resource "aws_security_group_rule" "kor_lambda_to_db" {
  provider                 = aws.seoul
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_kor.id
  source_security_group_id = aws_security_group.lambda_sg.id
}

# ============= Oregon Region DB Cluster =============
resource "aws_security_group" "db_usa" {
  provider    = aws.oregon
  name        = "SecurityGroup-DB-Cluster-Oregon"
  description = "USA Aurora MySQL access"
  vpc_id      = var.usa_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----- RDS Proxy ----> DB Cluster
resource "aws_security_group_rule" "usa_proxy_to_db" {
  provider                 = aws.oregon
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.db_usa.id
  source_security_group_id = aws_security_group.proxy_usa.id
}

# ============= Oregon Region RDS Proxy =============
resource "aws_security_group" "proxy_usa" {
  provider    = aws.oregon
  name        = "SecurityGroup-RDSproxy-Oregon"
  vpc_id      = var.usa_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----- EKS Workers ----> Proxy
resource "aws_security_group_rule" "usa_eks_to_proxy" {
  count                    = var.oregon_eks_workers_sg_id == null ? 0 : 1
  provider                 = aws.oregon
  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.proxy_usa.id
  source_security_group_id = var.oregon_eks_workers_sg_id
}

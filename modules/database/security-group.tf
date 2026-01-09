# ============= Seoul Region DB Cluster =============
resource "aws_security_group" "db_kor" {
  provider = aws.seoul

  name          = "SecurityGroup-DB-Cluster-Seoul"
  description   = "KOR Aurora MySQL access"
  vpc_id        = var.kor_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----- RDS Proxy ----> DB Cluster 
resource "aws_security_group_rule" "kor_eks_to_db" {
  provider = aws.seoul

  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"

  security_group_id        = aws_security_group.db_kor.id
  source_security_group_id = aws_security_group.proxy_kor.id
}

# ----- Terraform ----> DB Cluster (Aurora Writer)
resource "aws_security_group_rule" "allow_terraform_kor_db" {
  provider = aws.seoul

  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"

  security_group_id = aws_security_group.db_kor.id
  cidr_blocks       = [var.onprem_public_ip]  # Terraform 실행 머신 공인 IP
}

# ============= Seoul Region RDS Proxy =============
resource "aws_security_group" "proxy_kor" {
  provider      = aws.seoul

  name          = "SecurityGroup-RDSproxy-Seoul"
  vpc_id        = var.kor_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----- EKS Workers ----> Proxy
resource "aws_security_group_rule" "kor_eks_to_proxy" {
  provider = aws.seoul

  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.proxy_kor.id
  source_security_group_id = var.seoul_eks_workers_sg_id
}
# ----- Terraform ----> Proxy
resource "aws_security_group_rule" "allow_terraform_kor_proxy" {
  provider = aws.seoul

  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = [var.onprem_public_ip]  # Terraform 실행 머신의 공인 IP
  security_group_id = aws_security_group.proxy_kor.id
}

# ============= Oregon Region DB Cluster =============
resource "aws_security_group" "db_usa" {
  provider = aws.oregon

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
# ----- Terraform ----> DB Cluster (Aurora Writer)
resource "aws_security_group_rule" "allow_terraform_usa_db" {
  provider = aws.oregon

  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"

  security_group_id = aws_security_group.db_usa.id
  cidr_blocks       = [var.onprem_public_ip]  # Terraform 실행 머신 공인 IP
}

# ----- RDS Proxy ----> DB Cluster
resource "aws_security_group_rule" "usa_eks_to_db" {
  provider = aws.oregon

  type                     = "ingress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"

  security_group_id        = aws_security_group.db_usa.id
  source_security_group_id = aws_security_group.proxy_usa.id
}

# ============= Oregon Region RDS Proxy =============
resource "aws_security_group" "proxy_usa" {
  provider      = aws.oregon

  name          = "SecurityGroup-RDSproxy-Oregon"
  vpc_id        = var.usa_vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ----- EKS Workers ----> Proxy
resource "aws_security_group_rule" "usa_eks_to_proxy" {
  provider                 = aws.oregon

  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.proxy_usa.id
  source_security_group_id = var.oregon_eks_workers_sg_id
}

# ----- Terraform ----> Proxy
resource "aws_security_group_rule" "allow_terraform_usa_proxy" {
  provider                 = aws.oregon

  type              = "ingress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = [var.onprem_public_ip]  # Terraform 실행 머신의 공인 IP
  security_group_id = aws_security_group.proxy_usa.id
}

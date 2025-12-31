resource "aws_security_group" "db_kor" {
  provider = aws.seoul

  name        = "kor-db-sg"
  description = "KOR Aurora MySQL access"
  vpc_id      = module.kor_vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "kor_eks_to_db" {
  provider = aws.seoul

  type                     = "ingress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"

  security_group_id        = aws_security_group.db_kor.id
  source_security_group_id = aws_security_group.eks_node_sg_kor.id
}

resource "aws_security_group" "db_usa" {
  provider = aws.oregon

  name        = "usa-db-sg"
  description = "USA Aurora MySQL access"
  vpc_id      = module.usa_vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "usa_eks_to_db" {
  provider = aws.oregon

  type                     = "ingress"
  from_port               = 3306
  to_port                 = 3306
  protocol                = "tcp"

  security_group_id        = aws_security_group.db_usa.id
  source_security_group_id = aws_security_group.eks_node_sg_usa.id
}


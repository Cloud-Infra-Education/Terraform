resource "aws_security_group" "db_kor" {
  provider = aws.seoul

  name        = "sg-db-cluster-seoul"
  description = "KOR Aurora MySQL access"
  vpc_id      = var.kor_vpc_id

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
  source_security_group_id = var.seoul_eks_workers_sg_id
}

resource "aws_security_group" "db_usa" {
  provider = aws.oregon

  name        = "sg-db-cluster-oregon"
  description = "USA Aurora MySQL access"
  vpc_id      = var.usa_vpc_id

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
  source_security_group_id = var.oregon_eks_workers_sg_id
}

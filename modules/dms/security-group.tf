resource "aws_security_group" "dms" {
  name   = "${var.our_team}-dms-replication-sg"
  vpc_id = var.vpc_id
}

############################
# DMS → On-Prem (egress)
############################
resource "aws_security_group_rule" "dms_to_onprem_db" {
  type              = "egress"
  from_port         = var.onprem_db_port
  to_port           = var.onprem_db_port
  protocol          = "tcp"
  cidr_blocks       = [var.onprem_cidr]
  security_group_id = aws_security_group.dms.id
}

############################
# DMS → KOR DB (egress)
############################
resource "aws_security_group_rule" "dms_to_source_db" {
  type              = "egress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = ["10.10.0.0/16"] # KOR DB CIDR
  security_group_id = aws_security_group.dms.id
}

############################
# DMS → USA DB (egress)
############################
resource "aws_security_group_rule" "dms_to_target_db" {
  type              = "egress"
  from_port         = var.db_port
  to_port           = var.db_port
  protocol          = "tcp"
  cidr_blocks       = ["10.11.0.0/16"] # USA DB CIDR
  security_group_id = aws_security_group.dms.id
}

############################
# KOR DB ← DMS (ingress)
############################
resource "aws_security_group_rule" "kor_db_from_dms" {
  provider = aws.seoul

  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"

  security_group_id        = var.source_db_sg_id
  source_security_group_id = aws_security_group.dms.id
}

############################
# USA DB ← DMS (ingress)
############################
resource "aws_security_group_rule" "usa_db_from_dms" {
  provider = aws.oregon

  type                     = "ingress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"

  security_group_id        = var.target_db_sg_id
  source_security_group_id = aws_security_group.dms.id
}


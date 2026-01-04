resource "aws_security_group" "dms" {
  name   = "dms-replication-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "dms_to_source_db" {
  type                     = "egress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dms.id
  source_security_group_id = var.source_db_sg_id
}

resource "aws_security_group_rule" "dms_to_target_db" {
  type                     = "egress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dms.id
  source_security_group_id = var.target_db_sg_id
}


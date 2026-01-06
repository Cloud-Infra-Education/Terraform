resource "aws_security_group" "dms" {
  name   = "${var.our_team}-dms-replication-sg"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "dms_to_source_db" {
  type                     = "egress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dms.id
  cidr_blocks              = ["10.10.0.0/16"]
}

resource "aws_security_group_rule" "dms_to_target_db" {
  type                     = "egress"
  from_port                = var.db_port
  to_port                  = var.db_port
  protocol                 = "tcp"
  security_group_id        = aws_security_group.dms.id
  cidr_blocks              = ["10.11.0.0/16"]
}


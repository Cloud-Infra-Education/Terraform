locals {
  normalized_prefix = substr(lower(replace(var.name_prefix, "/[^a-z0-9-/]", "-")), 0, 40)

  replication_instance_id = "dms-${local.normalized_prefix}-ri"
  source_endpoint_id      = "dms-${local.normalized_prefix}-src"
  target_endpoint_id      = "dms-${local.normalized_prefix}-tgt"
  replication_task_id     = "dms-${local.normalized_prefix}-task"
}

resource "aws_security_group" "dms" {
  name        = "${local.replication_instance_id}-sg"
  description = "AWS DMS replication instance SG"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.replication_instance_id}-sg"
  })
}

resource "aws_security_group_rule" "dms_to_target_db" {
  count = var.target_db_security_group_id == null ? 0 : 1

  type                     = "ingress"
  security_group_id        = var.target_db_security_group_id
  source_security_group_id = aws_security_group.dms.id

  from_port   = var.target_port
  to_port     = var.target_port
  protocol    = "tcp"
  description = "Allow DMS replication instance to connect to target DB"
}

resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "${local.replication_instance_id}-subnet-group"
  replication_subnet_group_description = "Subnets for DMS replication instance"
  subnet_ids                           = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${local.replication_instance_id}-subnet-group"
  })
}

resource "aws_dms_replication_instance" "this" {
  replication_instance_id    = local.replication_instance_id
  replication_instance_class = var.replication_instance_class
  allocated_storage          = var.allocated_storage

  publicly_accessible = var.publicly_accessible
  multi_az            = var.multi_az

  vpc_security_group_ids      = [aws_security_group.dms.id]
  replication_subnet_group_id = aws_dms_replication_subnet_group.this.id

  kms_key_arn = var.kms_key_arn

  preferred_maintenance_window = var.preferred_maintenance_window

  tags = merge(var.tags, {
    Name = local.replication_instance_id
  })

  depends_on = [
    aws_iam_role_policy_attachment.dms_vpc_role,
    aws_iam_role_policy_attachment.dms_cloudwatch_logs_role,
  ]
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = local.source_endpoint_id
  endpoint_type = "source"
  engine_name   = var.source_engine_name

  server_name   = var.source_server_name
  port          = var.source_port
  database_name = var.source_database_name
  username      = var.source_username
  password      = var.source_password
  ssl_mode      = var.source_ssl_mode

  extra_connection_attributes = var.source_extra_connection_attributes

  tags = merge(var.tags, {
    Name = local.source_endpoint_id
  })
}

resource "aws_dms_endpoint" "target" {
  endpoint_id   = local.target_endpoint_id
  endpoint_type = "target"
  engine_name   = var.target_engine_name

  server_name   = var.target_server_name
  port          = var.target_port
  database_name = var.target_database_name
  username      = var.target_username
  password      = var.target_password
  ssl_mode      = var.target_ssl_mode

  extra_connection_attributes = var.target_extra_connection_attributes

  tags = merge(var.tags, {
    Name = local.target_endpoint_id
  })
}

resource "aws_dms_replication_task" "this" {
  start_replication_task = var.start_replication_task

  replication_task_id       = local.replication_task_id
  replication_instance_arn  = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn       = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn       = aws_dms_endpoint.target.endpoint_arn
  migration_type            = var.migration_type
  table_mappings            = var.table_mappings
  replication_task_settings = var.replication_task_settings

  tags = merge(var.tags, {
    Name = local.replication_task_id
  })
}


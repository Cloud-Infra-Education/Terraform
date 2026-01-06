resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id          = "dms-subnet-group"
  replication_subnet_group_description = "DMS replication subnet group"
  subnet_ids                           = var.subnet_ids
}

resource "aws_dms_replication_instance" "this" {
  replication_instance_id        = "${var.our_team}-dms-repl"
  replication_instance_class     = "dms.t3.medium"
  replication_subnet_group_id    = aws_dms_replication_subnet_group.this.id
  vpc_security_group_ids         = [aws_security_group.dms.id]
}

resource "aws_dms_endpoint" "source" {
  endpoint_id   = "source-db"
  endpoint_type = "source"
  engine_name   = "mysql"
  username      = var.db_username
  password      = var.db_password
  server_name   = var.source_db_endpoint
  port          = var.db_port
  database_name = var.source_db_name
}

resource "aws_dms_endpoint" "target" {
  endpoint_id   = "target-db"
  endpoint_type = "target"
  engine_name   = "mysql"
  username      = var.db_username
  password      = var.db_password
  server_name   = var.target_db_endpoint
  port          = var.db_port
  database_name = var.target_db_name
}

resource "aws_dms_replication_task" "kor_to_usa_full_load" {
  replication_task_id      = "${var.our_team}-kor-to-usa-full-load"
  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn
  migration_type           = "full-load"
  table_mappings           = file("${path.module}/table-mappings.json")

  replication_task_settings = jsonencode({
    TargetMetadata = {
      TargetSchema   = ""
      SupportLobs    = true
      FullLobMode    = false
      LobChunkSize   = 64
      LimitedSizeLobMode = true
      LobMaxSize     = 32
      BatchApplyEnabled = true
      # MySQL target에서 ParallelLoad 옵션 제거
    }
    FullLoadSettings = {
      TargetTablePrepMode = "DO_NOTHING"
      CreatePkAfterFullLoad = false
      MaxFullLoadSubTasks   = 8
      TransactionConsistencyTimeout = 600
      CommitRate = 10000
    }
    Logging = { EnableLogging = true }
  })
}

resource "time_sleep" "wait_before_dms_start" {
  depends_on      = [var.db_kor_cluster_id, var.db_usa_cluster_id]  
  create_duration = "300s"  # DB 인스턴스 안정화 고려, 필요시 조정
}

resource "null_resource" "start_dms_task_once" {
  triggers = {
    task_arn = aws_dms_replication_task.kor_to_usa_full_load.replication_task_arn
  }

  depends_on = [time_sleep.wait_before_dms_start]

  provisioner "local-exec" {
    command = <<EOT
aws dms start-replication-task \
  --replication-task-arn ${aws_dms_replication_task.kor_to_usa_full_load.replication_task_arn} \
  --start-replication-task-type start-replication
EOT
  }
}


resource "aws_dms_replication_subnet_group" "this" {
  replication_subnet_group_id = "dms-subnet-group"
  subnet_ids                  = var.subnet_ids
}

resource "aws_dms_replication_instance" "this" {
  replication_instance_id = "dms-repl"
  replication_instance_class = "dms.t3.medium"

  vpc_security_group_ids = [aws_security_group.dms.id]
  replication_subnet_group_id = aws_dms_replication_subnet_group.this.id
}

resource "aws_dms_replication_task" "kor_to_usa_full_load" {
  replication_task_id = "kor-to-usa-full-load"

  migration_type = "full-load"

  replication_instance_arn = aws_dms_replication_instance.this.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.arn
  target_endpoint_arn      = aws_dms_endpoint.target.arn

  table_mappings = file("${path.module}/table-mappings.json")

  replication_task_settings = jsonencode({
    TargetMetadata = {
      TargetSchema                 = ""
      SupportLobs                  = true
      FullLobMode                  = false
      LobChunkSize                 = 64
      LimitedSizeLobMode           = true
      LobMaxSize                   = 32
      BatchApplyEnabled            = true
      ParallelLoadThreads          = 8
      ParallelLoadBufferSize       = 50
    }

    FullLoadSettings = {
      TargetTablePrepMode          = "DO_NOTHING"
      CreatePkAfterFullLoad        = false
      StopTaskCachedChangesApplied = false
      StopTaskCachedChangesNotApplied = false
      MaxFullLoadSubTasks          = 8
      TransactionConsistencyTimeout = 600
      CommitRate                   = 10000
    }

    Logging = {
      EnableLogging = true
    }
  })
}

resource "null_resource" "start_dms_task_once" {
  triggers = {
    task_arn = aws_dms_replication_task.kor_to_usa_full_load.replication_task_arn
  }

  depends_on = [
    time_sleep.wait_before_dms_start
  ]

  provisioner "local-exec" {
    command = <<EOT
aws dms start-replication-task \
  --replication-task-arn ${aws_dms_replication_task.kor_to_usa_full_load.replication_task_arn} \
  --start-replication-task-type start-replication
EOT
  }
}

resource "time_sleep" "wait_before_dms_start" {
  depends_on      = [aws_dms_replication_task.kor_to_usa_full_load]
  create_duration = "60s"
}


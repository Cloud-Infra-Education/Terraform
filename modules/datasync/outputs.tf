output "task_arn" {
  value = aws_datasync_task.this.arn
}

/*
output "migration_sg_id" {
  value = aws_security_group.migration_sg.id
}
*/

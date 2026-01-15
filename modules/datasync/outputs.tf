output "task_arn" {
  value = aws_datasync_task.this.arn
}

output "target_bucket_name" {
  value = aws_s3_bucket.migration_target.bucket
}
/*
output "migration_sg_id" {
  value = aws_security_group.migration_sg.id
}
*/

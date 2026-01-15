# 1. 목적지 S3 Location 설정 (인프라 버킷 참조)
resource "aws_datasync_location_s3" "destination" {
  s3_bucket_arn = var.target_bucket_arn
  subdirectory  = "/migrated_data"

  s3_config {
    bucket_access_role_arn = aws_iam_role.this.arn
  }

  depends_on = [aws_iam_role_policy.s3_access]
}

# 2. On-Premise Location (NFS)
resource "aws_datasync_location_nfs" "source" {
  server_hostname = var.onprem_private_ip
  subdirectory    = var.onprem_source_path

  on_prem_config {
    agent_arns = [var.datasync_agent_arn]
  }
}

# 3. DataSync Task
resource "aws_datasync_task" "this" {
  name                     = "${var.our_team}-sync-task"
  source_location_arn      = aws_datasync_location_nfs.source.arn
  destination_location_arn = aws_datasync_location_s3.destination.arn

  options {
    verify_mode = "ONLY_FILES_TRANSFERRED"
    mtime       = "PRESERVE"
    atime       = "BEST_EFFORT"
  }
}



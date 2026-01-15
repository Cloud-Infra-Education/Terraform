# 1. 고유한 버킷 생성을 위한 랜덤 ID
resource "random_id" "bucket_id" {
  byte_length = 4
}

# 2. 목적지 S3 버킷
resource "aws_s3_bucket" "migration_target" {
  bucket = "${var.our_team}-migration-${random_id.bucket_id.hex}"
}

# 3. S3 Location
resource "aws_datasync_location_s3" "destination" {
  s3_bucket_arn = aws_s3_bucket.migration_target.arn
  subdirectory  = "/migrated_data"

  s3_config {
    bucket_access_role_arn = aws_iam_role.this.arn
  }
  
  depends_on = [aws_iam_role_policy.s3_access]
}

# 4. On-Premise Location (NFS)
resource "aws_datasync_location_nfs" "source" {
  server_hostname = var.onprem_private_ip
  subdirectory    = var.onprem_source_path

  on_prem_config {
    agent_arns = [var.datasync_agent_arn]
  }
}

# 5. DataSync Task
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

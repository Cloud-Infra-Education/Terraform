output "video_processor_repo_url" {
  value = aws_ecr_repository.video_processor.repository_url
}
output "alert_service_repo_url" {
  value = aws_ecr_repository.alert_service.repository_url
}

output "user_service_repository_url" {
  value = aws_ecr_repository.user.repository_url
}

output "backend_api_repository_url" {
  value = aws_ecr_repository.backend_api.repository_url
}


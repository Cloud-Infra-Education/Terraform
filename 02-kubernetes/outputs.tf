output "seoul_cluster_name" {
  value = module.eks.seoul_cluster_name
}

output "seoul_cluster_endpoint" {
  value = module.eks.seoul_cluster_endpoint
}

output "seoul_cluster_certificate_authority_data" {
  value = module.eks.seoul_cluster_certificate_authority_data
}

output "seoul_oidc_provider_arn" {
  value = module.eks.seoul_oidc_provider_arn
}

output "seoul_eks_workers_sg_id" {
  value = module.eks.seoul_eks_workers_sg_id
}

output "oregon_cluster_name" {
  value = module.eks.oregon_cluster_name
}

output "oregon_cluster_endpoint" {
  value = module.eks.oregon_cluster_endpoint
}

output "oregon_cluster_certificate_authority_data" {
  value = module.eks.oregon_cluster_certificate_authority_data
}

output "oregon_oidc_provider_arn" {
  value = module.eks.oregon_oidc_provider_arn
}

output "oregon_eks_workers_sg_id" {
  value = module.eks.oregon_eks_workers_sg_id
}

# ECR Repository URLs
output "user_service_repository_url" {
  description = "User Service ECR Repository URL"
  value       = module.ecr.user_service_repository_url
}

output "backend_api_repository_url" {
  description = "Backend API ECR Repository URL"
  value       = module.ecr.backend_api_repository_url
}


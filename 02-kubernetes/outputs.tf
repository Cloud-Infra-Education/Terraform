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
output "video_processor_repo_url" {
  value = module.ecr.video_processor_repo_url
}

output "alert_service_repo_url" {
  value = module.ecr.alert_service_repo_url
}

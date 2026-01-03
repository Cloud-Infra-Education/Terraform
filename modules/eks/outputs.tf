# ========== Seoul Region ============
output "seoul_cluster_name" {
  value = module.eks_seoul.cluster_name
}

output "seoul_cluster_endpoint" {
  value = module.eks_seoul.cluster_endpoint
}

output "seoul_cluster_certificate_authority_data" {
  value = module.eks_seoul.cluster_certificate_authority_data
}

output "seoul_oidc_provider_arn" {
  value = module.eks_seoul.oidc_provider_arn
}

output "seoul_eks_workers_sg_id" {
  value = module.eks_seoul.node_security_group_id
}

# ========== Oregon Region ============
output "oregon_cluster_name" {
  value = module.eks_oregon.cluster_name
}

output "oregon_cluster_endpoint" {
  value = module.eks_oregon.cluster_endpoint
}

output "oregon_cluster_certificate_authority_data" {
  value = module.eks_oregon.cluster_certificate_authority_data
}

output "oregon_oidc_provider_arn" {
  value = module.eks_oregon.oidc_provider_arn
}

output "oregon_eks_workers_sg_id" {
  value = module.eks_oregon.node_security_group_id
}

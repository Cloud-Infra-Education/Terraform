# ============================================================
# - AWS Load Balancer Controller(IRSA 포함)
# ============================================================

module "addons" {
  source = "../modules/addons"

  providers = {
    aws.seoul         = aws.seoul
    aws.oregon        = aws.oregon
    kubernetes        = kubernetes
    kubernetes.oregon = kubernetes.oregon
    helm              = helm
    helm.oregon       = helm.oregon
  }

  kor_vpc_id = data.terraform_remote_state.infra.outputs.kor_vpc_id
  usa_vpc_id = data.terraform_remote_state.infra.outputs.usa_vpc_id

  eks_seoul_cluster_name       = data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name
  eks_seoul_oidc_provider_arn  = data.terraform_remote_state.kubernetes.outputs.seoul_oidc_provider_arn
  eks_oregon_cluster_name      = data.terraform_remote_state.kubernetes.outputs.oregon_cluster_name
  eks_oregon_oidc_provider_arn = data.terraform_remote_state.kubernetes.outputs.oregon_oidc_provider_arn
}

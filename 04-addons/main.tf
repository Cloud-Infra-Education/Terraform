# ============================================================
# - AWS Load Balancer Controller(IRSA 포함)
# ============================================================

resource "null_resource" "seoul_fix_metrics_apiservice" {
  triggers = {
    cluster_name = data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name ${data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name} --region ap-northeast-2
      kubectl delete apiservice v1.metrics.eks.amazonaws.com --ignore-not-found=true
    EOT
  }
}


module "addons" {
  source = "../modules/addons"

  depends_on = [
    null_resource.seoul_fix_metrics_apiservice
  ]

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

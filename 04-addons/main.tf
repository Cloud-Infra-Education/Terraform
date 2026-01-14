# ============================================================
# - AWS Load Balancer Controller(IRSA 포함)
# ============================================================

# 주의: metrics API service 삭제는 수동으로 처리하거나
# EKS 클러스터에 접근 가능한 환경에서 실행해야 합니다.
# 현재 서버에서 EKS 클러스터 접근이 안 되는 경우,
# 아래 null_resource는 주석 처리하고 나중에 수동으로 처리하세요.

# resource "null_resource" "seoul_fix_metrics_apiservice" {
#   triggers = {
#     cluster_name = data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name
#   }
#
#   provisioner "local-exec" {
#     command = <<-EOT
#       aws eks update-kubeconfig --name ${data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name} --region ap-northeast-2
#       kubectl delete apiservice v1.metrics.eks.amazonaws.com --ignore-not-found=true
#     EOT
#   }
# }
#
# resource "null_resource" "oregon_fix_metrics_apiservice" {
#   triggers = {
#     cluster_name = data.terraform_remote_state.kubernetes.outputs.oregon_cluster_name
#   }
#
#   provisioner "local-exec" {
#     command = <<-EOT
#       aws eks update-kubeconfig --name ${data.terraform_remote_state.kubernetes.outputs.oregon_cluster_name} --region us-west-2
#       kubectl delete apiservice v1.metrics.eks.amazonaws.com --ignore-not-found=true
#     EOT
#   }
# }

module "addons" {
  source = "../modules/addons"

  # depends_on 제거 (null_resource 주석 처리로 인해)

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

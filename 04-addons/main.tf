# ============================================================
# 04-addons/main.tf
# - 팀장님 지시사항: Metrics API 충돌 해결을 위한 null_resource 추가 및 의존성 설정
# ============================================================

# 1. 서울 클러스터 Metrics API 서비스 강제 삭제
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

# 2. 오레곤 클러스터 Metrics API 서비스 강제 삭제
resource "null_resource" "oregon_fix_metrics_apiservice" {
  triggers = {
    cluster_name = data.terraform_remote_state.kubernetes.outputs.oregon_cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig --name ${data.terraform_remote_state.kubernetes.outputs.oregon_cluster_name} --region us-west-2
      kubectl delete apiservice v1.metrics.eks.amazonaws.com --ignore-not-found=true
    EOT
  }
}

# 3. Addons 모듈 배포 (의존성 추가)
module "addons" {
  source = "../modules/addons"

  # [중요] API 서비스 삭제가 완료된 후 실행되도록 설정
  depends_on = [
    null_resource.seoul_fix_metrics_apiservice,
    null_resource.oregon_fix_metrics_apiservice
  ]

  providers = {
    aws.seoul         = aws.seoul
    aws.oregon        = aws.oregon
    kubernetes        = kubernetes
    kubernetes.oregon = kubernetes.oregon
    helm              = helm
    helm.oregon       = helm.oregon
  }

  # 인프라 리소스 정보 전달
  kor_vpc_id = data.terraform_remote_state.infra.outputs.kor_vpc_id
  usa_vpc_id = data.terraform_remote_state.infra.outputs.usa_vpc_id

  # 클러스터 정보 전달
  eks_seoul_cluster_name       = data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name
  eks_seoul_oidc_provider_arn  = data.terraform_remote_state.kubernetes.outputs.seoul_oidc_provider_arn
  eks_oregon_cluster_name      = data.terraform_remote_state.kubernetes.outputs.oregon_cluster_name
  eks_oregon_oidc_provider_arn = data.terraform_remote_state.kubernetes.outputs.oregon_oidc_provider_arn
}

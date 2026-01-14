# ============================================================
# - ArgoCD 설치 + (선택) Application 생성
# ============================================================

module "argocd" {
  source = "../modules/argocd"

  providers = {
    helm              = helm
    helm.oregon       = helm.oregon
    kubernetes        = kubernetes
    kubernetes.oregon = kubernetes.oregon
  }

  argocd_namespace     = var.argocd_namespace
  argocd_chart_version = var.argocd_chart_version

  argocd_app_name                  = var.argocd_app_name
  argocd_app_repo_url              = var.argocd_app_repo_url
  argocd_app_path                  = var.argocd_app_path
  argocd_app_target_revision       = var.argocd_app_target_revision
  argocd_app_destination_namespace = var.argocd_app_destination_namespace
  argocd_app_enabled               = var.argocd_app_enabled
}

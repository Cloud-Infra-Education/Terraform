# ============================================================
# - App Monitoring (LGTM + Alloy)
# - 
# ============================================================
module "app_monitoring_seoul" {
  source = "../modules/app-monitoring"

  providers = {
    aws        = aws.seoul
    kubernetes = kubernetes
    helm       = helm
  }

  eks_cluster_name = data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name
  region           = "ap-northeast-2"

  name_prefix = "formation-lap"
  namespace   = "app-monitoring-seoul"

}

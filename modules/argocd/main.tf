locals {
  argocd_helm_repo     = "https://argoproj.github.io/argo-helm"
  argocd_helm_chart    = "argo-cd"
  argocd_release_name  = "argocd"
}

# -------------------------
# Seoul: Namespace + Helm
# -------------------------
resource "helm_release" "argocd_seoul" {
  name       = local.argocd_release_name
  repository = local.argocd_helm_repo
  chart      = local.argocd_helm_chart
  namespace  = var.argocd_namespace

  create_namespace = true
  version          = var.argocd_chart_version != "" ? var.argocd_chart_version : null

  wait    = true
  timeout = 600

  set {
    name  = "crds.install"
    value = "true"
  }

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

}

# -------------------------
# Oregon: Namespace + Helm
# -------------------------
resource "helm_release" "argocd_oregon" {
  provider   = helm.oregon
  name       = local.argocd_release_name
  repository = local.argocd_helm_repo
  chart      = local.argocd_helm_chart
  namespace  = var.argocd_namespace

  create_namespace = true
  version          = var.argocd_chart_version != "" ? var.argocd_chart_version : null

  wait    = true
  timeout = 600

  set {
    name  = "crds.install"
    value = "true"
  }

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }
}


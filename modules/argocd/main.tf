locals {
  argocd_helm_repo    = "https://argoproj.github.io/argo-helm"
  argocd_helm_chart   = "argo-cd"
  argocd_release_name = "argocd"

  argocd_application_manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = var.argocd_app_name
      namespace = var.argocd_namespace
      labels = {
        managed-by = "terraform"
      }
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }

    spec = {
      project = "default"
      source = {
        repoURL        = var.argocd_app_repo_url
        path           = var.argocd_app_path
        targetRevision = var.argocd_app_target_revision
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = var.argocd_app_destination_namespace
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true",
        ]
      }
    }
  }
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

resource "kubernetes_manifest" "argocd_app_seoul" {
  count      = var.argocd_app_enabled ? 1 : 0
  manifest   = local.argocd_application_manifest
  depends_on = [helm_release.argocd_seoul]
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

resource "kubernetes_manifest" "argocd_app_oregon" {
  count      = var.argocd_app_enabled ? 1 : 0
  provider   = kubernetes.oregon
  manifest   = local.argocd_application_manifest
  depends_on = [helm_release.argocd_oregon]
}

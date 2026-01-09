# ==============================
# Layer 4 - Alloy (Helm)
# ==============================

locals {
  alloy_config = templatefile("${path.module}/alloy/config.alloy.tmpl", {
    loki_push_url            = "${local.loki_gateway_url}/loki/api/v1/push"
    mimir_remote_write_url   = "${local.mimir_nginx_url}/api/v1/push"
    tempo_otlp_grpc_endpoint = local.tempo_otlp_grpc_endpoint
    tenant_id                = var.tenant_org_id
  })
}

resource "helm_release" "alloy_seoul" {
  name      = local.releases.alloy
  namespace = var.namespace

  repository = "https://grafana.github.io/helm-charts"
  chart      = "alloy"
  version    = var.alloy_chart_version

  create_namespace = false

  values = [
    yamlencode({
      fullnameOverride = local.releases.alloy

      rbac = {
        create = true
      }

      serviceAccount = {
        create = true
        name   = local.service_accounts.alloy
      }

      alloy = {
        configMap = {
          create  = true
          content = local.alloy_config
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring,
  ]
}

# Expose OTLP ports in-cluster so workloads can send traces to Alloy.
resource "kubernetes_service_v1" "alloy_otlp" {
  metadata {
    name      = "${local.releases.alloy}-otlp"
    namespace = var.namespace
  }

  spec {
    type = "ClusterIP"

    selector = {
      "app.kubernetes.io/instance" = local.releases.alloy
      "app.kubernetes.io/name"     = "alloy"
    }

    port {
      name        = "otlp-grpc"
      port        = 4317
      target_port = 4317
      protocol    = "TCP"
    }

    port {
      name        = "otlp-http"
      port        = 4318
      target_port = 4318
      protocol    = "TCP"
    }
  }

  depends_on = [
    helm_release.alloy_seoul,
  ]
}


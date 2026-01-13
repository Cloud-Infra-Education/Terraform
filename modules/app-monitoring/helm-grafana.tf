# ==============================
# Layer 4 - Grafana (Helm)
# ==============================

resource "random_password" "grafana_admin" {
  length  = 24
  special = true
}

resource "helm_release" "grafana_seoul" {
  name      = local.releases.grafana
  namespace = var.namespace

  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = var.grafana_chart_version

  create_namespace = false

  values = [
    yamlencode({
      fullnameOverride = local.releases.grafana

      serviceAccount = {
        create = true
        name   = local.service_accounts.grafana
      }

      service = {
        type = "ClusterIP"
        port = 80
      }

      adminUser     = "admin"
      adminPassword = coalesce(var.grafana_admin_password, random_password.grafana_admin.result)

      persistence = {
        enabled = false
      }

      # Minimal provisioning: LGTM datasources with tenant header.
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Loki"
              type      = "loki"
              access    = "proxy"
              url       = local.loki_gateway_url
              isDefault = false
              jsonData = {
                httpHeaderName1 = "X-Scope-OrgID"
              }
              secureJsonData = {
                httpHeaderValue1 = "chan"
              }
            },
            {
              name      = "AMP"
              type      = "prometheus"
              access    = "proxy"
              url       = local.amp_query_base_url
              isDefault = true
            },
            {
              name   = "Tempo"
              type   = "tempo"
              access = "proxy"
              url    = "http://${local.releases.tempo}-query-frontend.${var.namespace}.svc.cluster.local:3200"
              jsonData = {
                httpHeaderName1 = "X-Scope-OrgID"
              }
              secureJsonData = {
                httpHeaderValue1 = "chan"
              }
            }
          ]
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring,
    kubernetes_service_v1.amp_query_sigv4_proxy_seoul,
  ]
}


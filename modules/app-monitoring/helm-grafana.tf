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
              uid       = "loki"
              access    = "proxy"
              url       = local.loki_gateway_url
              isDefault = false
              jsonData = {
                httpHeaderName1 = "X-Scope-OrgID"
              }
              secureJsonData = {
                httpHeaderValue1 = "monitoring"
              }
            },
            {
              name      = "AMP"
              type      = "prometheus"
              uid       = "amp"
              access    = "proxy"
              url       = local.amp_query_base_url
              isDefault = true
            },
            {
              name   = "Tempo"
              type   = "tempo"
              uid    = "tempo"
              access = "proxy"
              url    = "http://${local.releases.tempo}-query-frontend.${var.namespace}.svc.cluster.local:3200"
              jsonData = {
                httpHeaderName1 = "X-Scope-OrgID"
              }
              secureJsonData = {
                httpHeaderValue1 = "monitoring"
              }
            }
          ]
        }
      }

      # Auto-load dashboards from ConfigMaps labeled grafana_dashboard=1.
      sidecar = {
        dashboards = {
          enabled        = true
          label          = "grafana_dashboard"
          labelValue     = "1"
          searchNamespace = var.namespace
          folder         = "/tmp/dashboards"
        }
      }

      dashboardProviders = {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers = [
            {
              name            = "default"
              orgId           = 1
              folder          = ""
              type            = "file"
              disableDeletion = false
              editable        = true
              options = {
                path = "/tmp/dashboards"
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



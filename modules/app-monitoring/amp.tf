# ==============================
# AMP (Amazon Managed Prometheus)
# - Workspace
# - SigV4 proxies (remote_write, query)
# ==============================

resource "aws_prometheus_workspace" "seoul" {
  alias = local.amp_workspace_alias
}

# -----------------
# Kubernetes: IRSA service accounts
# -----------------

resource "kubernetes_service_account_v1" "amp_remote_write_sa_seoul" {
  metadata {
    name      = local.service_accounts.amp_remote_write
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.amp_remote_write_seoul.arn
    }
  }

  depends_on = [kubernetes_namespace_v1.monitoring]
}

resource "kubernetes_service_account_v1" "amp_query_sa_seoul" {
  metadata {
    name      = local.service_accounts.amp_query
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.amp_query_seoul.arn
    }
  }

  depends_on = [kubernetes_namespace_v1.monitoring]
}

# -----------------
# Kubernetes: SigV4 proxy for remote_write
# -----------------

resource "kubernetes_deployment_v1" "amp_remote_write_sigv4_proxy_seoul" {
  metadata {
    name      = var.amp_remote_write_proxy_service_name
    namespace = var.namespace
    labels    = { app = var.amp_remote_write_proxy_service_name }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = var.amp_remote_write_proxy_service_name }
    }

    template {
      metadata {
        labels = { app = var.amp_remote_write_proxy_service_name }
      }

      spec {
        service_account_name = local.service_accounts.amp_remote_write

        container {
          name  = "aws-sigv4-proxy"
          image = var.amp_sigv4_proxy_image

          args = [
            "--name",
            "aps",
            "--region",
            var.region,
            "--host",
            local.amp_host,
            "--port",
            ":${var.amp_sigv4_proxy_port}",
#            tostring(var.amp_sigv4_proxy_port),
          ]

          port {
            container_port = var.amp_sigv4_proxy_port
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service_account_v1.amp_remote_write_sa_seoul]
}

resource "kubernetes_service_v1" "amp_remote_write_sigv4_proxy_seoul" {
  metadata {
    name      = var.amp_remote_write_proxy_service_name
    namespace = var.namespace
  }

  spec {
    selector = { app = var.amp_remote_write_proxy_service_name }

    port {
      name        = "http"
      port        = var.amp_sigv4_proxy_port
      target_port = var.amp_sigv4_proxy_port
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment_v1.amp_remote_write_sigv4_proxy_seoul]
}

# -----------------
# Kubernetes: SigV4 proxy for query (Grafana datasource)
# -----------------

resource "kubernetes_deployment_v1" "amp_query_sigv4_proxy_seoul" {
  metadata {
    name      = var.amp_query_proxy_service_name
    namespace = var.namespace
    labels    = { app = var.amp_query_proxy_service_name }
  }

  spec {
    replicas = 1

    selector {
      match_labels = { app = var.amp_query_proxy_service_name }
    }

    template {
      metadata {
        labels = { app = var.amp_query_proxy_service_name }
      }

      spec {
        service_account_name = local.service_accounts.amp_query

        container {
          name  = "aws-sigv4-proxy"
          image = var.amp_sigv4_proxy_image

          args = [
            "--name",
            "aps",
            "--region",
            var.region,
            "--host",
            local.amp_host,
            "--port",
            ":${var.amp_sigv4_proxy_port}",
#           tostring(var.amp_sigv4_proxy_port),
          ]

          port {
            container_port = var.amp_sigv4_proxy_port
          }
        }
      }
    }
  }

  depends_on = [kubernetes_service_account_v1.amp_query_sa_seoul]
}

resource "kubernetes_service_v1" "amp_query_sigv4_proxy_seoul" {
  metadata {
    name      = var.amp_query_proxy_service_name
    namespace = var.namespace
  }

  spec {
    selector = { app = var.amp_query_proxy_service_name }

    port {
      name        = "http"
      port        = var.amp_sigv4_proxy_port
      target_port = var.amp_sigv4_proxy_port
    }

    type = "ClusterIP"
  }

  depends_on = [kubernetes_deployment_v1.amp_query_sigv4_proxy_seoul]
}


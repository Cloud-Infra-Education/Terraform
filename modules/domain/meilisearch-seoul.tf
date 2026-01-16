# ============================================================
# Meilisearch Deployment (Seoul)
# ============================================================

resource "kubernetes_deployment_v1" "meilisearch_seoul" {
  metadata {
    name      = "meilisearch"
    namespace = "formation-lap"
    labels = {
      app = "meilisearch"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "meilisearch"
      }
    }

    template {
      metadata {
        labels = {
          app = "meilisearch"
        }
      }

      spec {
        container {
          name  = "meilisearch"
          image = "getmeili/meilisearch:latest"

          port {
            container_port = 7700
            name           = "http"
          }

          env {
            name  = "MEILI_MASTER_KEY"
            value = var.meilisearch_api_key != "" ? var.meilisearch_api_key : "masterKey1234567890"
          }

          env {
            name  = "MEILI_ENV"
            value = "development"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 7700
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = 7700
            }
            initial_delay_seconds = 10
            period_seconds        = 5
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "meilisearch_seoul" {
  metadata {
    name      = "meilisearch-service"
    namespace = "formation-lap"
    labels = {
      app = "meilisearch"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "meilisearch"
    }

    port {
      name        = "http"
      port        = 7700
      target_port = 7700
      protocol    = "TCP"
    }
  }

  depends_on = [kubernetes_deployment_v1.meilisearch_seoul]
}

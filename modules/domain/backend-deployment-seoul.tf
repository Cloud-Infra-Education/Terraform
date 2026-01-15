# Backend API Deployment for Seoul
resource "kubernetes_deployment_v1" "backend_api_seoul" {
  wait_for_rollout = false  # 이미지가 없을 때도 deployment 생성 허용

  metadata {
    name      = "backend-api"
    namespace = "formation-lap"
    labels = {
      app = "backend-api"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "backend-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend-api"
        }
      }

      spec {
        service_account_name = kubernetes_service_account_v1.backend_api_sa.metadata[0].name
        
        container {
          name  = "backend-api"
          image = "${var.ecr_repository_url}:latest"  # ECR 이미지 URL (레포지토리 이름 포함)

          port {
            container_port = 8000
            name          = "http"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map_v1.backend_config_seoul.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret_v1.backend_secrets_seoul.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "200m"
              memory = "512Mi"
            }
            limits = {
              cpu    = "1000m"
              memory = "1Gi"
            }
          }

          readiness_probe {
            http_get {
              path = "/api/v1/health"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds       = 10
            timeout_seconds      = 5
            failure_threshold    = 3
          }

          liveness_probe {
            http_get {
              path = "/api/v1/health"
              port = 8000
            }
            initial_delay_seconds = 30
            period_seconds       = 30
            timeout_seconds      = 5
            failure_threshold    = 3
          }
        }
      }
    }
  }
}

# Backend API Service
resource "kubernetes_service_v1" "backend_api_service_seoul" {
  metadata {
    name      = "backend-api-service"
    namespace = "formation-lap"
    labels = {
      app = "backend-api"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "backend-api"
    }

    port {
      port        = 8000
      target_port = 8000
      protocol    = "TCP"
      name        = "http"
    }
  }
}

# Backend ConfigMap (비밀 정보 제외)
resource "kubernetes_config_map_v1" "backend_config_seoul" {
  metadata {
    name      = "backend-config"
    namespace = "formation-lap"
  }

  data = {
    # Application
    APP_NAME    = "Backend API"
    APP_VERSION = "1.0.0"
    DEBUG       = "false"
    ENVIRONMENT = "production"

    # Server
    HOST = "0.0.0.0"
    PORT = "8000"
    
    # FastAPI root_path 설정 (Ingress의 /api prefix를 위해)
    ROOT_PATH = "/api"

    # Keycloak (URL만 설정, 나머지는 Secret)
    KEYCLOAK_URL    = "https://${var.api_subdomain}.${var.domain_name}/keycloak"
    KEYCLOAK_REALM  = "formation-lap"
    KEYCLOAK_CLIENT_ID = "backend-client"

    # JWT
    JWT_ALGORITHM = "RS256"

    # Meilisearch (URL만 설정, API Key는 Secret)
    MEILISEARCH_URL = var.meilisearch_url != "" ? var.meilisearch_url : "http://meilisearch-service:7700"

    # Database (RDS Proxy 사용)
    DB_PORT = "3306"
    DB_NAME = var.db_name

    # S3 & CloudFront
    S3_BUCKET_NAME     = var.origin_bucket_name
    S3_REGION          = var.origin_bucket_region
    CLOUDFRONT_DOMAIN  = "${var.www_subdomain}.${var.domain_name}"
  }
}

# Backend Secrets (비밀 정보)
resource "kubernetes_secret_v1" "backend_secrets_seoul" {
  metadata {
    name      = "backend-secrets"
    namespace = "formation-lap"
  }

  type = "Opaque"

  data = {
    # Keycloak (Terraform이 자동으로 base64 인코딩 처리)
    KEYCLOAK_CLIENT_SECRET   = var.keycloak_client_secret != "" ? var.keycloak_client_secret : ""
    KEYCLOAK_ADMIN_USERNAME  = var.keycloak_admin_username != "" ? var.keycloak_admin_username : "admin"
    KEYCLOAK_ADMIN_PASSWORD  = var.keycloak_admin_password != "" ? var.keycloak_admin_password : "admin"

    # Meilisearch
    MEILISEARCH_API_KEY = var.meilisearch_api_key != "" ? var.meilisearch_api_key : "masterKey1234567890"

    # Database (RDS Proxy endpoint 사용, TLS 필수)
    # ssl_disabled=false를 제거해야 pymysql이 SSL을 사용함 (database.py에서 SSL 설정)
    DATABASE_URL = "mysql+pymysql://${var.db_username}:${var.db_password}@${var.kor_db_proxy_endpoint}:3306/${var.db_name}?charset=utf8mb4"
  }
}

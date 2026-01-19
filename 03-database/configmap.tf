# ============================================================
# ConfigMap 생성 (하드코딩된 값 변수화)
# ============================================================

# DB ConfigMap 생성 (하드코딩된 값 제거)
resource "kubernetes_config_map" "db_config" {
  provider = kubernetes.seoul
  
  metadata {
    name      = "db-config"
    namespace = "formation-lap"
  }

  data = {
    DB_HOST     = module.database.kor_rds_proxy_endpoint
    DB_USER     = "proxy_admin"
    DB_NAME     = "ott_db"
    REGION_NAME = "ap-northeast-2"
  }

  depends_on = [
    module.database,
    data.aws_eks_cluster.seoul
  ]
}

# Backend API ConfigMap 생성 (하드코딩된 값 제거)
resource "kubernetes_config_map" "backend_config" {
  provider = kubernetes.seoul
  
  metadata {
    name      = "backend-config"
    namespace = "formation-lap"
  }

  data = {
    APP_NAME          = "Backend API"
    APP_VERSION       = "1.0.0"
    DEBUG             = "false"
    ENVIRONMENT       = "production"
    HOST              = "0.0.0.0"
    PORT              = "8000"
    ROOT_PATH         = "/api"
    KEYCLOAK_URL      = coalesce(var.keycloak_url, "https://api.${var.domain_name}/keycloak")
    KEYCLOAK_REALM    = "formation-lap"
    KEYCLOAK_CLIENT_ID = "backend-client"
    JWT_ALGORITHM     = "RS256"
    MEILISEARCH_URL   = "http://meilisearch-service:7700"
    DB_PORT           = "3306"
    DB_NAME           = "ott_db"
    S3_BUCKET_NAME    = data.terraform_remote_state.infra.outputs.origin_bucket_name
    S3_REGION         = "ap-northeast-2"
    CLOUDFRONT_DOMAIN = coalesce(var.cloudfront_domain, "www.${var.domain_name}")
  }

  depends_on = [
    data.terraform_remote_state.infra,
    data.aws_eks_cluster.seoul
  ]
}

# Keycloak ConfigMap 생성 (하드코딩된 값 제거)
resource "kubernetes_config_map" "keycloak_config" {
  provider = kubernetes.seoul
  
  metadata {
    name      = "keycloak-config"
    namespace = "formation-lap"
  }

  data = {
    KEYCLOAK_URL       = coalesce(var.keycloak_url, "https://api.${var.domain_name}/keycloak")
    KEYCLOAK_REALM     = "formation-lap"
    KEYCLOAK_CLIENT_ID = "backend-client"
  }

  depends_on = [
    data.aws_eks_cluster.seoul
  ]
}


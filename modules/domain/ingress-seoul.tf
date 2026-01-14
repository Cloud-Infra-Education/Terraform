resource "kubernetes_namespace_v1" "formation_lap_seoul" {
  metadata {
    name = "formation-lap"
  }
}

resource "kubernetes_manifest" "msa_ingress_seoul" {
  #  provider = kubernetes.seoul

  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "msa-ingress"
      namespace = "formation-lap"
      annotations = {
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"        = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "matchacake-alb-test-seoul"
        
        "alb.ingress.kubernetes.io/wafv2-acl-arn" = var.seoul_waf_web_acl_arn

        "alb.ingress.kubernetes.io/certificate-arn" = var.acm_arn_api_seoul
        "alb.ingress.kubernetes.io/listen-ports"    = "[{\"HTTPS\":443}]"

        # 80 -> 443 Redirect
        "alb.ingress.kubernetes.io/ssl-redirect" = "443"
      }
    }
    spec = {
      ingressClassName = "alb"
      rules = [
        {
          http = {
            paths = [
              {
                path     = "/api"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "backend-api-service"
                    port = { number = 8000 }
                  }
                }
              },
              {
                path     = "/api/docs"
                pathType = "Exact"
                backend = {
                  service = {
                    name = "backend-api-service"
                    port = { number = 8000 }
                  }
                }
              },
              {
                path     = "/api/openapi.json"
                pathType = "Exact"
                backend = {
                  service = {
                    name = "backend-api-service"
                    port = { number = 8000 }
                  }
                }
              },
              {
                path     = "/docs"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "backend-api-service"
                    port = { number = 8000 }
                  }
                }
              },
              {
                path     = "/users"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "user-service"
                    port = { number = 8000 }
                  }
                }
              },
              {
                path     = "/orders"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "order-service"
                    port = { number = 8000 }
                  }
                }
              },
              {
                path     = "/products"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "product-service"
                    port = { number = 8000 }
                  }
                }
              },
              {
                path     = "/keycloak"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "keycloak-service"
                    port = { number = 8080 }
                  }
                }
              }
            ]
          }
        }
      ]
    }
  }
}


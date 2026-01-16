resource "kubernetes_namespace_v1" "formation_lap_oregon" {
  provider = kubernetes.oregon

  metadata {
    name = "formation-lap"
  }
}

resource "kubernetes_manifest" "msa_ingress_oregon" {
  provider = kubernetes.oregon

  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "msa-ingress"
      namespace = "formation-lap"
      annotations = {
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"        = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "matchacake-alb-test-oregon"
 
        "alb.ingress.kubernetes.io/wafv2-acl-arn" = var.oregon_waf_web_acl_arn

        "alb.ingress.kubernetes.io/certificate-arn" = var.acm_arn_api_oregon
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


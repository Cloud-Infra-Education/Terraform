resource "kubernetes_manifest" "msa_ingress_oregon" {
  provider = kubernetes.oregon

  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "msa-ingress"
      namespace = "formation-lap"
      annotations = {
        "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"   = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "matchacake-alb-test-oregon"
 
        "alb.ingress.kubernetes.io/wafv2-acl-arn" = var.oregon_waf_web_acl_arn

        "alb.ingress.kubernetes.io/certificate-arn" = var.acm_arn_api_oregon
        "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
        
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
                path     = "/api"
                pathType = "Prefix"
                backend = {
                  service = {
                    name = "backend-api-service"
                    port = { number = 8000 }
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


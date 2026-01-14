# Keycloak Ingress for Oregon
resource "kubernetes_manifest" "keycloak_ingress_oregon" {
  provider = kubernetes.oregon

  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "keycloak-ingress"
      namespace = "formation-lap"
      annotations = merge(
        {
          "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"        = "ip"
          "alb.ingress.kubernetes.io/load-balancer-name" = "matchacake-alb-keycloak-oregon"
          "alb.ingress.kubernetes.io/listen-ports"      = var.acm_arn_keycloak_oregon != "" ? "[{\"HTTPS\":443}]" : "[{\"HTTP\":80}]"
        },
        var.acm_arn_keycloak_oregon != "" ? {
          "alb.ingress.kubernetes.io/certificate-arn" = var.acm_arn_keycloak_oregon
          "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
        } : {},
        var.oregon_waf_web_acl_arn != "" ? {
          "alb.ingress.kubernetes.io/wafv2-acl-arn" = var.oregon_waf_web_acl_arn
        } : {}
      )
    }
    spec = {
      ingressClassName = "alb"
      rules = [
        {
          host = var.keycloak_subdomain != "" ? "${var.keycloak_subdomain}.${var.domain_name}" : null
          http = {
            paths = [
              {
                path     = "/"
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

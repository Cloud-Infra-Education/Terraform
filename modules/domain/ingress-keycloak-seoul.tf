# Keycloak Ingress for Seoul
resource "kubernetes_manifest" "keycloak_ingress_seoul" {
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
          "alb.ingress.kubernetes.io/load-balancer-name" = "matchacake-alb-keycloak-seoul"
          "alb.ingress.kubernetes.io/listen-ports"       = var.acm_arn_keycloak_seoul != "" ? "[{\"HTTPS\":443}]" : "[{\"HTTP\":80}]"
        },
        var.acm_arn_keycloak_seoul != "" ? {
          "alb.ingress.kubernetes.io/certificate-arn" = var.acm_arn_keycloak_seoul
          "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
        } : {},
        var.seoul_waf_web_acl_arn != "" ? {
          "alb.ingress.kubernetes.io/wafv2-acl-arn" = var.seoul_waf_web_acl_arn
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

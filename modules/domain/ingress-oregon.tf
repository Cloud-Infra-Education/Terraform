<<<<<<< Updated upstream
resource "kubernetes_manifest" "msa_ingress_oregon" {
  provider = kubernetes.oregon

=======
# [수정] 팀장님 지시사항: ArgoCD 앱과 중복되지 않도록 네임스페이스 리소스 삭제

# 오레곤 클러스터에 Ingress 생성
resource "kubernetes_manifest" "msa_ingress_oregon" {
  provider = kubernetes.oregon

  # [삭제] depends_on = [kubernetes_namespace.oregon] 삭제

>>>>>>> Stashed changes
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "msa-ingress"
      namespace = "formation-lap" # 이미 생성된 네임스페이스 이름을 명시
      annotations = {
<<<<<<< Updated upstream
        "alb.ingress.kubernetes.io/scheme"        = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"   = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "matchacake-alb-test-oregon"
 
        "alb.ingress.kubernetes.io/wafv2-acl-arn" = var.oregon_waf_web_acl_arn

        "alb.ingress.kubernetes.io/certificate-arn" = var.acm_arn_api_oregon
        "alb.ingress.kubernetes.io/listen-ports" = "[{\"HTTPS\":443}]"
        
        # 80 -> 443 Redirect
        "alb.ingress.kubernetes.io/ssl-redirect" = "443"
=======
        "alb.ingress.kubernetes.io/scheme"             = "internet-facing"
        "alb.ingress.kubernetes.io/target-type"        = "ip"
        "alb.ingress.kubernetes.io/load-balancer-name" = "matchacake-alb-test-oregon"
        "alb.ingress.kubernetes.io/wafv2-acl-arn"      = var.oregon_waf_web_acl_arn
        "alb.ingress.kubernetes.io/certificate-arn"    = var.acm_arn_api_oregon
        "alb.ingress.kubernetes.io/listen-ports"       = "[{\"HTTPS\":443}]"
        "alb.ingress.kubernetes.io/ssl-redirect"       = "443"
>>>>>>> Stashed changes
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
              }
            ]
          }
        }
      ]
    }
  }
}


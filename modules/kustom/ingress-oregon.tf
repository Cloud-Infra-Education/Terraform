# provider "kubernetes" {
#   alias                  = "seoul"
#   host                   = data.aws_eks_cluster.seoul.endpoint
#   cluster_ca_certificate = base64decode(data.aws_eks_cluster.seoul.certificate_authority[0].data)
#   token                  = data.aws_eks_cluster_auth.seoul.token
# }

variable "namespace" {
  type    = string
  default = "formation-lap"
}

variable "alb_name" {
  type    = string
  default = "matchacake-alb-test"
}

# HTTPS를 쓸 거면 cert arn을 넘겨주고, HTTP만이면 빈 문자열로 둬도 됨.
variable "acm_arn" {
  type    = string
  default = ""
}

resource "kubernetes_manifest" "msa_ingress" {
  provider = kubernetes.seoul

  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "Ingress"
    metadata = {
      name      = "msa-ingress"
      namespace = var.namespace
      annotations = merge(
        {
          "alb.ingress.kubernetes.io/scheme"            = "internet-facing"
          "alb.ingress.kubernetes.io/target-type"       = "ip"
          "alb.ingress.kubernetes.io/load-balancer-name" = var.alb_name
        },
        var.acm_arn != "" ? {
          # HTTPS 리스너 활성화
          "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTPS\":443}]"
          "alb.ingress.kubernetes.io/certificate-arn"  = var.acm_arn

          # 원하면 80->443 리다이렉트도 같이
          # "alb.ingress.kubernetes.io/ssl-redirect" = "443"
        } : {}
      )
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


# Keycloak Route53 Record
# Keycloak ALB를 직접 연결 (API는 Global Accelerator, www는 CloudFront와 동일하게 별도 설정)

# ALB는 Ingress 생성 후에 생성되므로, 
# Ingress의 annotations에서 load-balancer-name을 사용하여 찾음
data "aws_lb" "keycloak_seoul" {
  provider = aws.seoul
  name     = "matchacake-alb-keycloak-seoul"
  
  depends_on = [
    kubernetes_manifest.keycloak_ingress_seoul
  ]
}

data "aws_lb" "keycloak_oregon" {
  provider = aws.oregon
  name     = "matchacake-alb-keycloak-oregon"
  
  depends_on = [
    kubernetes_manifest.keycloak_ingress_oregon
  ]
}

# Keycloak Route53 A 레코드 - Seoul ALB를 Primary로 사용
resource "aws_route53_record" "keycloak_a" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.keycloak_subdomain != "" ? "${var.keycloak_subdomain}.${var.domain_name}" : null
  type    = "A"

  alias {
    name                   = data.aws_lb.keycloak_seoul.dns_name
    zone_id                = data.aws_lb.keycloak_seoul.zone_id
    evaluate_target_health = true
  }

  depends_on = [
    kubernetes_manifest.keycloak_ingress_seoul,
    data.aws_lb.keycloak_seoul
  ]
}

# Oregon을 Failover로 추가 (선택사항)
# resource "aws_route53_record" "keycloak_a_oregon" {
#   zone_id = data.aws_route53_zone.public.zone_id
#   name    = var.keycloak_subdomain != "" ? "${var.keycloak_subdomain}.${var.domain_name}" : null
#   type    = "A"
#   set_identifier = "oregon"
# 
#   alias {
#     name                   = data.aws_lb.keycloak_oregon.dns_name
#     zone_id                = data.aws_lb.keycloak_oregon.zone_id
#     evaluate_target_health = true
#   }
# 
#   failover_routing_policy {
#     type = "SECONDARY"
#   }
# 
#   depends_on = [
#     kubernetes_manifest.keycloak_ingress_oregon,
#     data.aws_lb.keycloak_oregon
#   ]
# }

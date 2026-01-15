# Route 53 Hosted Zone 조회 (zone_id가 제공되지 않은 경우에만 사용)
data "aws_route53_zone" "public" {
  # Route 53은 글로벌 서비스이므로 기본 provider 사용 (권한 문제 방지)
  count        = var.route53_zone_id == "" ? 1 : 0
  name         = "${var.domain_name}."
  private_zone = false
}

# Local value로 zone_id 결정
locals {
  route53_zone_id = coalesce(
    var.route53_zone_id != "" ? var.route53_zone_id : null,
    try(data.aws_route53_zone.public[0].zone_id, null)
  )
}

locals {
  seoul_dvo = {
    #    for dvo in aws_acm_certificate.api_seoul.domain_validation_options :
    for dvo in var.dvo_api_seoul :
    "${dvo.resource_record_name}|${dvo.resource_record_type}" => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  oregon_dvo = {
    #    for dvo in aws_acm_certificate.api_oregon.domain_validation_options :
    for dvo in var.dvo_api_oregon :
    "${dvo.resource_record_name}|${dvo.resource_record_type}" => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  validation_records = merge(local.seoul_dvo, local.oregon_dvo)
}

#============= CloudFront용 A 레코드 등록 =============
resource "aws_route53_record" "www_a" {
  # Route 53은 글로벌 서비스이므로 기본 provider 사용 (권한 문제 방지)
  zone_id = local.route53_zone_id
  name    = local.www_fqdn
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.www.domain_name
    zone_id                = aws_cloudfront_distribution.www.hosted_zone_id
    evaluate_target_health = false
  }
}

#============= CloudFront용 CNAME 레코드 등록 =============
resource "aws_route53_record" "www_cert_validation" {
  # Route 53은 글로벌 서비스이므로 기본 provider 사용 (권한 문제 방지)
  for_each = {
    #    for dvo in aws_acm_certificate.www.domain_validation_options : dvo.domain_name => {
    for dvo in var.dvo_www :
    dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id = local.route53_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.value]
}

#============= Global Accelerator(ALB)용 CNAME 레코드 등록 =============
resource "aws_route53_record" "api_cert_validation" {
  # Route 53은 글로벌 서비스이므로 기본 provider 사용 (권한 문제 방지)
  #for_each = var.acm_validation_records ?  local.validation_records : {}
  for_each = local.validation_records

  zone_id         = local.route53_zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

#============= API ALB 직접 연결 (Global Accelerator 없이) =============
# 주석: Global Accelerator를 사용하므로 이 레코드는 08-domain-ga에서 생성됩니다
# Seoul ALB를 data source로 가져오기
# data "aws_lb" "api_seoul" {
#   provider = aws.seoul
#   name     = "matchacake-alb-test-seoul"
# }

# api.matchacake.click A 레코드 (Seoul ALB 직접 연결)
# 주석: Global Accelerator를 사용하므로 이 리소스는 비활성화
# resource "aws_route53_record" "api_a" {
#   zone_id = local.route53_zone_id
#   name    = "${var.api_subdomain}.${var.domain_name}"
#   type    = "A"
#
#   alias {
#     name                   = data.aws_lb.api_seoul.dns_name
#     zone_id                = data.aws_lb.api_seoul.zone_id
#     evaluate_target_health = true
#   }
# }


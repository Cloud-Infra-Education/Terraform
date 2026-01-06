data "aws_route53_zone" "public" {
  name = var.domain_name
  private_zone = false
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
  zone_id = data.aws_route53_zone.public.zone_id
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
  for_each = {
#    for dvo in aws_acm_certificate.www.domain_validation_options : dvo.domain_name => {
    for dvo in var.dvo_www : 
      dvo.domain_name => {
      name  = dvo.resource_record_name
      type  = dvo.resource_record_type
      value = dvo.resource_record_value
    }
  }

  zone_id  = data.aws_route53_zone.public.zone_id
  name     = each.value.name
  type     = each.value.type
  ttl      = 60
  records  = [each.value.value]
}

#============= Global Accelerator(ALB)용 CNAME 레코드 등록 =============
resource "aws_route53_record" "api_cert_validation" {
  #for_each = var.acm_validation_records ?  local.validation_records : {}
  for_each =  local.validation_records 

  zone_id         = data.aws_route53_zone.public.zone_id
  name            = each.value.name
  type            = each.value.type
  ttl             = 60
  records         = [each.value.value]
  allow_overwrite = true
}

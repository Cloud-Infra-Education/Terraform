data "aws_route53_zone" "public" {
  name = var.domain_name
  private_zone = false
}

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

resource "aws_route53_record" "www_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.www.domain_validation_options : dvo.domain_name => {
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

# ============================================
resource "aws_route53_record" "api_a" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = "${var.api_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_globalaccelerator_accelerator.this.dns_name
    zone_id                = aws_globalaccelerator_accelerator.this.hosted_zone_id
    evaluate_target_health = false
  }
}

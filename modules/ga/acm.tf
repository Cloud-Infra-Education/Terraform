data "aws_route53_zone" "public" {
  name = var.domain_name
  private_zone = false
}

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


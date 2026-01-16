# Route 53 Hosted Zone 조회 (zone_id가 제공되지 않은 경우에만 사용)
data "aws_route53_zone" "public" {
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

resource "aws_route53_record" "api_a" {
  zone_id = local.route53_zone_id
  name    = "${var.api_subdomain}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_globalaccelerator_accelerator.this.dns_name
    zone_id                = aws_globalaccelerator_accelerator.this.hosted_zone_id
    evaluate_target_health = false
  }
}


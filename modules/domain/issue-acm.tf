#locals {
#  www_fqdn = "${var.www_subdomain}.${var.domain_name}"
#  s3_rest_domain    = "${var.origin_bucket_name}.s3.${var.origin_bucket_region}.amazonaws.com"
#  origin_id         = "team-formation-lap-origin-s3"
#}

#locals {
#  api_fqdn = "${var.api_subdomain}.${var.domain_name}"
#}

# =========== CloudFront ACM ===========
#resource "aws_acm_certificate" "www" {
#  provider          = aws.acm
#  domain_name       = local.www_fqdn
#  validation_method = "DNS"
#}
resource "aws_acm_certificate_validation" "www" {
  provider = aws.acm
  #  certificate_arn         = aws_acm_certificate.www.arn
  certificate_arn         = var.acm_arn_www
  validation_record_fqdns = [for r in aws_route53_record.www_cert_validation : r.fqdn]
}

# =========== Seoul ALB ACM ===========
#resource "aws_acm_certificate" "api_seoul" {
#  provider          = aws.seoul
#  domain_name       = local.api_fqdn
#  validation_method = "DNS"
#}
resource "aws_acm_certificate_validation" "api_seoul" {
  provider = aws.seoul
  #  certificate_arn         = aws_acm_certificate.api_seoul.arn
  certificate_arn         = var.acm_arn_api_seoul
  validation_record_fqdns = [for r in aws_route53_record.api_cert_validation : r.fqdn]
}

# =========== Oregon ALB ACM ===========
#resource "aws_acm_certificate" "api_oregon" {
#  provider          = aws.oregon
#  domain_name       = local.api_fqdn
#  validation_method = "DNS"
#}
resource "aws_acm_certificate_validation" "api_oregon" {
  provider = aws.oregon
  #  certificate_arn         = aws_acm_certificate.api_oregon.arn
  certificate_arn         = var.acm_arn_api_oregon
  validation_record_fqdns = [for r in aws_route53_record.api_cert_validation : r.fqdn]
}

locals {
  www_fqdn = "${var.www_subdomain}.${var.domain_name}"
  s3_rest_domain    = "${var.origin_bucket_name}.s3.${var.origin_bucket_region}.amazonaws.com"
  origin_id         = "${var.our_team}-origin-s3"
}

locals {
  api_fqdn = "${var.api_subdomain}.${var.domain_name}"
}




# 서울리전 CNAME 생성
resource "aws_acm_certificate" "cname_api_seoul" {
  provider          = aws.seoul
  domain_name       = local.api_fqdn
  validation_method = "DNS"
}

# 오레곤 리전 CNAME 생성
resource "aws_acm_certificate" "cname_api_oregon" {
  provider          = aws.oregon
  domain_name       = local.api_fqdn
  validation_method = "DNS"
}

# us-east-1 리전 CNAME 생성(CloudFront 용)
resource "aws_acm_certificate" "a_www" {
  provider          = aws.acm
  domain_name       = local.www_fqdn
  validation_method = "DNS"
}


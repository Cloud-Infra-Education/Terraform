output "acm_arn_api_seoul" {
  value = aws_acm_certificate.cname_api_seoul.arn
}
output "acm_arn_api_oregon" {
  value = aws_acm_certificate.cname_api_oregon.arn
}
output "acm_arn_www" {
  value = aws_acm_certificate.a_www.arn
}
output "acm_arn_keycloak_seoul" {
  value = aws_acm_certificate.keycloak_seoul.arn
}
output "acm_arn_keycloak_oregon" {
  value = aws_acm_certificate.keycloak_oregon.arn
}

output "dvo_api_seoul" {
  value = aws_acm_certificate.cname_api_seoul.domain_validation_options
}
output "dvo_api_oregon" {
  value = aws_acm_certificate.cname_api_oregon.domain_validation_options
}
output "dvo_www" {
  value = aws_acm_certificate.a_www.domain_validation_options
}
output "dvo_keycloak_seoul" {
  value = aws_acm_certificate.keycloak_seoul.domain_validation_options
}
output "dvo_keycloak_oregon" {
  value = aws_acm_certificate.keycloak_oregon.domain_validation_options
}
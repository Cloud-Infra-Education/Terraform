# ===== ACM =====
output "acm_arn_api_seoul" {
  value = module.acm.acm_arn_api_seoul
}

output "acm_arn_api_oregon" {
  value = module.acm.acm_arn_api_oregon
}

output "acm_arn_www" {
  value = module.acm.acm_arn_www
}

output "dvo_api_seoul" {
  value = module.acm.dvo_api_seoul
}

output "dvo_api_oregon" {
  value = module.acm.dvo_api_oregon
}

output "dvo_www" {
  value = module.acm.dvo_www
}

# ===== WAF =====
# output "cloudfront_waf_web_acl_arn" {
#   value = module.waf.cloudfront_web_acl_arn
# }
#
# output "seoul_waf_web_acl_arn" {
#   value = module.waf.seoul_web_acl_arn
# }
#
# output "oregon_waf_web_acl_arn" {
#   value = module.waf.oregon_web_acl_arn
# }

variable "our_team" {
  type = string
}
# =========================
# Route53 도메인 & A 레코드
# =========================
variable "domain_name" {
  type = string
}

variable "api_subdomain" {
  type    = string
  default = "api"
}

variable "www_subdomain" {
  type    = string
  default = "www"
}

variable "keycloak_subdomain" {
  type    = string
  default = "keycloak"
  description = "Keycloak subdomain (e.g., 'keycloak' for keycloak.matchacake.click)"
}
# ===============
# CloudFront 관련 
# ===============
#버킷명 
variable "origin_bucket_name" {
  type = string
}

variable "origin_bucket_region" {
  type    = string
  default = "ap-northeast-2"
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}


# ===============
# WAF (WAFv2)
# ===============
# CloudFront는 scope=CLOUDFRONT WebACL ARN
variable "cloudfront_waf_web_acl_arn" {
  type    = string
  default = ""
}

# ALB(Seoul) scope=REGIONAL WebACL ARN
variable "seoul_waf_web_acl_arn" {
  type    = string
  default = ""
}

# ALB(Oregon) scope=REGIONAL WebACL ARN
variable "oregon_waf_web_acl_arn" {
  type    = string
  default = ""
}


# ======= ACM Output 참조변수 =======
variable "acm_arn_api_seoul" {
  type = string
}
variable "acm_arn_api_oregon" {
  type = string
}
variable "acm_arn_www" {
  type = string
}
variable "acm_arn_keycloak_seoul" {
  type = string
  description = "ACM certificate ARN for Keycloak in Seoul region"
}
variable "acm_arn_keycloak_oregon" {
  type = string
  description = "ACM certificate ARN for Keycloak in Oregon region"
}
variable "dvo_api_seoul" {
  type = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}
variable "dvo_api_oregon" {
  type = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}
variable "dvo_www" {
  type = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
}
variable "dvo_keycloak_seoul" {
  type    = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
  default = []
}
variable "dvo_keycloak_oregon" {
  type    = list(object({
    domain_name           = string
    resource_record_name  = string
    resource_record_type  = string
    resource_record_value = string
  }))
  default = []
}



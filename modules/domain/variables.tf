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

# ===============
# Backend API 배포 관련 변수
# ===============
variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL for Backend API image"
  default     = ""
}

variable "kor_db_proxy_endpoint" {
  type        = string
  description = "Korea RDS Proxy endpoint"
  default     = ""
}

variable "db_username" {
  type        = string
  description = "Database username"
  default     = ""
  sensitive   = true
}

variable "db_password" {
  type        = string
  description = "Database password"
  default     = ""
  sensitive   = true
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "y2om_db"
}

variable "keycloak_client_secret" {
  type        = string
  description = "Keycloak client secret"
  default     = ""
  sensitive   = true
}

variable "keycloak_admin_username" {
  type        = string
  description = "Keycloak admin username"
  default     = "admin"
}

variable "keycloak_admin_password" {
  type        = string
  description = "Keycloak admin password"
  default     = "admin"
  sensitive   = true
}

variable "meilisearch_url" {
  type        = string
  description = "Meilisearch URL"
  default     = ""
}

variable "meilisearch_api_key" {
  type        = string
  description = "Meilisearch API key"
  default     = "masterKey123"
  sensitive   = true
}



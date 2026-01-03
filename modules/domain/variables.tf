variable "ga_name" {
  type        = string
}

variable "enabled" {
  description = "Whether the accelerator is enabled."
  type        = bool
  default     = true
}

variable "ip_address_type" {
  description = "IP address type for GA (IPV4 or DUAL_STACK)."
  type        = string
  default     = "IPV4"
}

variable "tags" {
  type = map(string)
  default = {
    RecordA : "api"
  }
}

# ==========================
# 태그를 가지고 ALB를 지정함
# ==========================
variable "alb_lookup_tag_key" {
  type        = string
  default     = "ingress.k8s.aws/stack"
}

variable "alb_lookup_tag_value" {
  type        = string
}

# ======================
# GA Listener : 443 포트
# ======================
variable "listener_protocol" {
  description = "GA listener protocol. For ALB endpoints, TCP is the minimal option."
  type        = string
  default     = "TCP"
}

variable "listener_port" {
  description = "GA listener port."
  type        = number
  default     = 443
}

variable "client_affinity" {
  description = "Client affinity setting (NONE or SOURCE_IP)."
  type        = string
  default     = "NONE"
}

# ================
# Endpoint Groups
# ================
variable "seoul_region" {
  description = "Endpoint group region for Seoul."
  type        = string
  default     = "ap-northeast-2"
}

variable "oregon_region" {
  description = "Endpoint group region for Oregon."
  type        = string
  default     = "us-west-2"
}

variable "traffic_dial_percentage" {
  description = "Traffic dial percentage for each endpoint group (0-100)."
  type        = number
  default     = 100
}

variable "health_check_protocol" {
  description = "Health check protocol (TCP/HTTP/HTTPS)."
  type        = string
  default     = "TCP"
}

variable "health_check_port" {
  description = "Health check port."
  type        = number
  default     = 443
}

variable "seoul_weight" {
  description = "Weight for Seoul ALB endpoint (0-255)."
  type        = number
  default     = 128
}

variable "oregon_weight" {
  description = "Weight for Oregon ALB endpoint (0-255)."
  type        = number
  default     = 128
}

# =====================
# GA Listener : 80 포트 
# =====================
variable "http_listener_port" {
  type    = number
  default = 80
}

variable "http_listener_protocol" {
  type    = string
  default = "TCP"
}

variable "http_client_affinity" {
  type    = string
  default = "NONE"
}

variable "http_traffic_dial_percentage" {
  type    = number
  default = 100
}

variable "http_health_check_protocol" {
  type    = string
  default = "TCP"
}

variable "http_health_check_port" {
  type    = number
  default = 80
}

# =========================
# Route53 도메인 & A 레코드
# =========================
variable "domain_name" {
  type = string
}

variable "api_subdomain" {
  type = string
  default = "api"
}

variable "www_subdomain" {
  type = string
  default = "www"
}
# ===============
# CloudFront 관련 
# ===============

#variable "origin_domain_name" {
#  type        = string
#}

#버킷명 
variable "origin_bucket_name" {
  type        = string
}

variable "origin_bucket_region" {
  type        = string
  default     = "ap-northeast-2"
}

#variable "origin_protocol_policy" {
#  description = "Origin protocol policy: http-only | https-only | match-viewer"
#  type        = string
#  default     = "http-only"
#}

variable "default_root_object" {
  type        = string
  default     = "index.html"
}




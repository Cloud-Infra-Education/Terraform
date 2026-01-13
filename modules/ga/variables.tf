variable "ga_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "api_subdomain" {
  type    = string
  default = "api"
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

# ==========================
# 태그를 가지고 ALB를 지정함
# ==========================
variable "alb_lookup_tag_key" {
  type    = string
  default = "ingress.k8s.aws/stack"
}

variable "alb_lookup_tag_value" {
  type = string
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

# ==========================================
# [추가됨] GA Flow Logs를 위한 S3 버킷 변수
# ==========================================
variable "origin_bucket_name" {
  description = "The name of the S3 bucket where GA flow logs will be stored."
  type        = string
}

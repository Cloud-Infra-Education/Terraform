variable "cluster_id" {
  type = string
}

variable "region" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "secret_arn" {
  type = string
}

variable "iam_role_arn" {
  type = string
}

variable "proxy_require_tls" {
  type        = bool
  default     = false
}

variable "proxy_idle_client_timeout" {
  description = "Seconds"
  type        = number
  default     = 1800
}

variable "proxy_debug_logging" {
  type        = bool
  default     = false
}

variable "proxy_max_connections_percent" {
  type        = number
  default     = 100
}

variable "proxy_max_idle_connections_percent" {
  type        = number
  default     = 50
}

variable "proxy_connection_borrow_timeout" {
  description = "Seconds"
  type        = number
  default     = 120
}


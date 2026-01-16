variable "infra_state_path" {
  type    = string
  default = "../01-infra/terraform.tfstate"
}

variable "kubernetes_state_path" {
  type    = string
  default = "../02-kubernetes/terraform.tfstate"
}

variable "certificate_state_path" {
  type    = string
  default = "../06-certificate/terraform.tfstate"
}

variable "database_state_path" {
  type    = string
  default = "../03-database/terraform.tfstate"
}

variable "our_team" {
  type    = string
  default = "formation-lap"
}

variable "domain_name" {
  type = string
}

variable "route53_zone_id" {
  type        = string
  description = "Route 53 Hosted Zone ID (optional, if not provided will try to lookup by domain name)"
  default     = ""
}

variable "ecr_repository_url" {
  type        = string
  description = "ECR repository URL for Backend API image"
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

variable "origin_bucket_name" {
  type = string
}

variable "our_team" {
  type = string
}

variable "private_subnet_ids" {
  type        = list(string)
  default     = []
}

variable "ecr_url_video" {
  type        = string
  default     = null
}

variable "lambda_sg_id" {
  type        = string
  default     = null
}

variable "db_host"  {
	type    = string
  default = null
}

variable "db_username" {
  type    = string
  default = null
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = null
}

variable "db_name" {
  type        = string
  default     = "ott_db"
}

variable "lambda_role_arn" {
  type        = string
  description = "Lambda 함수 실행 역할 ARN (03-database에서 생성)"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for S3 Gateway Endpoint"
  default     = null
}

variable "private_route_table_ids" {
  type        = list(string)
  description = "List of private route table IDs for S3 Gateway Endpoint"
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for Lambda function"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for Lambda function"
  type        = list(string)
}

variable "origin_bucket_id" {
  description = "S3 bucket ID for origin"
  type        = string
}

variable "origin_bucket_arn" {
  description = "S3 bucket ARN for origin"
  type        = string
}

variable "origin_bucket_name" {
  description = "S3 bucket name for origin"
  type        = string
}

variable "catalog_api_base" {
  description = "Backend API base URL"
  type        = string
  default     = "https://api.exampleott.click"
}

variable "internal_token" {
  description = "Internal token for API authentication"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "db_host" {
  description = "Database host (RDS Proxy endpoint)"
  type        = string
  default     = ""
}

variable "db_resource_arn" {
  description = "RDS Data API resource ARN"
  type        = string
  default     = ""
}

variable "db_secret_arn" {
  description = "RDS secret ARN"
  type        = string
  default     = ""
}

variable "cloudfront_domain" {
  description = "CloudFront domain name"
  type        = string
  default     = "www.matchacake.click"
}

variable "tmdb_api_key" {
  description = "TMDB API key for movie metadata"
  type        = string
  sensitive   = true
  default     = ""
}

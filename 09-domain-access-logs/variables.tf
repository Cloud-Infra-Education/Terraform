variable "aws_region" {
  description = "AWS 리전"
  type        = string
  default     = "ap-northeast-2"
}

variable "route53_zone_id" {
  description = "Route53 Public Hosted Zone ID"
  type        = string
}

variable "opensearch_domain_name" {
  description = "OpenSearch 도메인 이름"
  type        = string
  default     = "y2om-route53-dns-logs"
}

variable "opensearch_instance_type" {
  description = "OpenSearch 인스턴스 타입"
  type        = string
  default     = "t3.small.search"
}

variable "opensearch_instance_count" {
  description = "OpenSearch 인스턴스 개수"
  type        = number
  default     = 1
}

variable "opensearch_version" {
  description = "OpenSearch 버전"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "log_retention_days" {
  description = "CloudWatch Logs 보존 기간 (일)"
  type        = number
  default     = 7
}

variable "lambda_function_name" {
  description = "Lambda 함수 이름"
  type        = string
  default     = "y2om-route53-dns-log-processor"
}

variable "opensearch_index_name" {
  description = "OpenSearch 인덱스 이름"
  type        = string
  default     = "y2om-route53-dns-logs"
}

variable "opensearch_create_service_linked_role" {
  description = "OpenSearch 서비스 링크드 역할 생성 여부"
  type        = bool
  default     = false
}

variable "opensearch_master_user_password" {
  description = "OpenSearch 마스터 사용자 비밀번호 (Fine-grained access control용)"
  type        = string
  sensitive   = true
  default     = "ChangeMe123!" # 기본값 - 실제 사용 시 반드시 변경 권장
}
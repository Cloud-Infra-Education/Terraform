variable "our_team" {
  description = "팀 이름(resource)"
  type        = string
}

variable "onprem_private_ip" {
  description = "온프레미스 파일 서버 IP"
  type        = string
}

variable "onprem_source_path" {
  description = "온프레미스 원본 디렉토리 경로"
  type        = string
  default     = "/mnt/my_data"
}

variable "datasync_agent_arn" {
  description = "수동으로 활성화한 DataSync Agent의 ARN"
  type        = string
}
/*
variable "vpc_id" {
  description = "보안 그룹이 생성될 VPC ID"
  type        = string
}
*/

variable "onprem_mg_private_cidr" {
  description = "온프레미스 네트워크 대역"
  type        = string
}

variable "target_bucket_arn" {
  description = "인프라에서 생성된 S3 버킷의 ARN"
  type        = string
}

variable "our_team" {
  type        = string
}

variable "aurora_cluster_id" {
  type        = string
}

variable "eks_cluster_name" {
  type        = string
}

variable "ecr_url_alert" {
  type        = string
}

variable "slack_secret_name" {
  type        = string
  default     = "formation-lap/slack/webhook"
}


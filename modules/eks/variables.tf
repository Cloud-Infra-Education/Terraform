variable "kor_vpc_id" {
  type = string
}

variable "kor_private_eks_subnet_ids" {
  type = list(string)
}

variable "usa_vpc_id" {
  type = string
}

variable "usa_private_eks_subnet_ids" {
  type = list(string)
}

variable "eks_public_access_cidrs" {
  description = "Allowed CIDR blocks for EKS public endpoint access"
  type        = list(string)
}

variable "eks_admin_principal_arn" {
  description = "Principal ARN to be granted EKS cluster admin access via EKS Access Entry"
  type        = string
}

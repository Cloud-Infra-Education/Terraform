# ============================================================
# 02-kubernetes
# - eks, ecr
# ============================================================

data "terraform_remote_state" "infra" {
  backend = "local"

  config = {
    path = var.infra_state_path
  }
}

module "eks" {
  source = "../modules/eks"

  providers = {
    aws.seoul   = aws.seoul
    aws.oregon  = aws.oregon
  }

  kor_vpc_id                 = data.terraform_remote_state.infra.outputs.kor_vpc_id
  kor_private_eks_subnet_ids = data.terraform_remote_state.infra.outputs.kor_private_eks_subnet_ids
  usa_vpc_id                 = data.terraform_remote_state.infra.outputs.usa_vpc_id
  usa_private_eks_subnet_ids = data.terraform_remote_state.infra.outputs.usa_private_eks_subnet_ids

  eks_public_access_cidrs = var.eks_public_access_cidrs
  eks_admin_principal_arn = var.eks_admin_principal_arn
}

module "ecr" {
  source = "../modules/ecr"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  ecr_replication_repo_prefixes = var.ecr_replication_repo_prefixes
}

# Root module: orchestrates per-domain modules.
module "network" {
  source = "./modules/network"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  key_name_kor = var.key_name_kor
  key_name_usa = var.key_name_usa
  admin_cidr   = var.admin_cidr
}

module "eks" {
  source = "./modules/eks"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  kor_vpc_id                 = module.network.kor_vpc_id
  kor_private_eks_subnet_ids  = module.network.kor_private_eks_subnet_ids
  usa_vpc_id                 = module.network.usa_vpc_id
  usa_private_eks_subnet_ids = module.network.usa_private_eks_subnet_ids

  eks_public_access_cidrs  = var.eks_public_access_cidrs
  eks_admin_principal_arn  = var.eks_admin_principal_arn
}

module "ecr" {
  source = "./modules/ecr"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  ecr_replication_repo_prefixes = var.ecr_replication_repo_prefixes
}

module "addons" {
  source = "./modules/addons"

  providers = {
    aws.seoul          = aws.seoul
    aws.oregon         = aws.oregon
    kubernetes         = kubernetes
    kubernetes.oregon  = kubernetes.oregon
    helm               = helm
    helm.oregon        = helm.oregon
  }

  kor_vpc_id = module.network.kor_vpc_id
  usa_vpc_id = module.network.usa_vpc_id

  eks_seoul_cluster_name      = module.eks.seoul_cluster_name
  eks_seoul_oidc_provider_arn = module.eks.seoul_oidc_provider_arn
  eks_oregon_cluster_name      = module.eks.oregon_cluster_name
  eks_oregon_oidc_provider_arn = module.eks.oregon_oidc_provider_arn
  
  depends_on = [module.eks]
}

module "argocd" {
  source = "./modules/argocd"
  
  providers = {
    helm               = helm
    helm.oregon        = helm.oregon
  }
  
  argocd_namespace = var.argocd_namespace
  argocd_chart_version = var.argocd_chart_version
}

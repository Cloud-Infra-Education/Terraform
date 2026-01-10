module "network" {
  source = "./modules/network"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  key_name_kor = var.key_name_kor
  key_name_usa = var.key_name_usa
  admin_cidr   = var.admin_cidr
  onprem_public_ip = var.onprem_public_ip
  onprem_private_cidr = var.onprem_private_cidr
}

module "eks" {
  source = "./modules/eks"

  providers = {
    aws.seoul   = aws.seoul
    aws.oregon  = aws.oregon
    helm        = helm
    helm.oregon = helm.oregon
  }

  kor_vpc_id                 = module.network.kor_vpc_id
  kor_private_eks_subnet_ids = module.network.kor_private_eks_subnet_ids
  usa_vpc_id                 = module.network.usa_vpc_id
  usa_private_eks_subnet_ids = module.network.usa_private_eks_subnet_ids

  eks_public_access_cidrs = var.eks_public_access_cidrs
  eks_admin_principal_arn = var.eks_admin_principal_arn
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
    aws.seoul         = aws.seoul
    aws.oregon        = aws.oregon
    kubernetes        = kubernetes
    kubernetes.oregon = kubernetes.oregon
    helm              = helm
    helm.oregon       = helm.oregon
  }

  kor_vpc_id = module.network.kor_vpc_id
  usa_vpc_id = module.network.usa_vpc_id

  eks_seoul_cluster_name       = module.eks.seoul_cluster_name
  eks_seoul_oidc_provider_arn  = module.eks.seoul_oidc_provider_arn
  eks_oregon_cluster_name      = module.eks.oregon_cluster_name
  eks_oregon_oidc_provider_arn = module.eks.oregon_oidc_provider_arn

  depends_on = [module.eks]
}

module "argocd" {
  source = "./modules/argocd"

  providers = {
    helm              = helm
    helm.oregon       = helm.oregon
    kubernetes        = kubernetes
    kubernetes.oregon = kubernetes.oregon
  }

  argocd_namespace     = var.argocd_namespace
  argocd_chart_version = var.argocd_chart_version

  argocd_app_name                  = var.argocd_app_name
  argocd_app_repo_url              = var.argocd_app_repo_url
  argocd_app_path                  = var.argocd_app_path
  argocd_app_target_revision       = var.argocd_app_target_revision
  argocd_app_destination_namespace = var.argocd_app_destination_namespace
  argocd_app_enabled               = var.argocd_app_enabled
}

module "s3" {
  source = "./modules/s3"

  origin_bucket_name = var.origin_bucket_name
}

module "acm" {
  source = "./modules/acm"
  
  providers = {
    aws.acm    = aws.acm
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  our_team = var.our_team
  domain_name = var.domain_name
  origin_bucket_name   = module.s3.origin_bucket_name
}

module "domain" {
  count = var.domain_set_enabled ? 1 : 0
  source = "./modules/domain"

  providers = {
    aws        = aws.oregon
    aws.acm    = aws.acm
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
    kubernetes        = kubernetes
    kubernetes.oregon = kubernetes.oregon
  }

  domain_name          = var.domain_name
  our_team             = var.our_team

  origin_bucket_name   = module.s3.origin_bucket_name

  cloudfront_waf_web_acl_arn = module.waf.cloudfront_web_acl_arn
  seoul_waf_web_acl_arn      = module.waf.seoul_web_acl_arn
  oregon_waf_web_acl_arn     = module.waf.oregon_web_acl_arn

  acm_arn_api_seoul    = module.acm.acm_arn_api_seoul
  acm_arn_api_oregon   = module.acm.acm_arn_api_oregon
  acm_arn_www          = module.acm.acm_arn_www
  dvo_api_seoul        = module.acm.dvo_api_seoul
  dvo_api_oregon       = module.acm.dvo_api_oregon
  dvo_www              = module.acm.dvo_www
}

module "ga" {
  count = var.ga_set_enabled ? 1 : 0
  source = "./modules/ga"
  
  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  ga_name              = var.ga_name
  alb_lookup_tag_value = var.alb_lookup_tag_value
  domain_name          = var.domain_name
}

module "database" {
#  count = var.db_cluster_enabled ? 1 : 0
  source = "./modules/database"
  
  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }
  kor_vpc_id                = module.network.kor_vpc_id
  usa_vpc_id                = module.network.usa_vpc_id
  kor_private_db_subnet_ids = module.network.kor_private_db_subnet_ids
  usa_private_db_subnet_ids = module.network.usa_private_db_subnet_ids
  seoul_eks_workers_sg_id   = module.eks.seoul_eks_workers_sg_id
  oregon_eks_workers_sg_id  = module.eks.oregon_eks_workers_sg_id
  
  db_username = var.db_username
  db_password = var.db_password
  our_team    = var.our_team
}

module "waf" {
  source = "./modules/waf"

  providers = {
    aws.acm    = aws.acm
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  our_team    = var.our_team
  domain_name = var.domain_name
}

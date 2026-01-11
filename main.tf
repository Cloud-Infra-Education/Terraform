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
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
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
  kor_db_endpoint = module.database.kor_db_cluster_endpoint
  usa_db_endpoint = module.database.usa_db_cluster_endpoint
  seoul_eks_workers_sg_id   = module.eks.seoul_eks_workers_sg_id
  oregon_eks_workers_sg_id  = module.eks.oregon_eks_workers_sg_id
  
  db_username = var.db_username
  db_password = var.db_password
  dms_db_username = var.dms_db_username
  dms_db_password = var.dms_db_password
  our_team    = var.our_team

  onprem_public_ip    = var.onprem_public_cidr
  onprem_private_cidr = var.onprem_private_cidr
  dms_security_group_id = var.dms_enabled ? module.dms[0].dms_security_group_id : null
}

module "proxy_primary_seoul" {
  source = "./modules/proxy/primary"

  providers = { aws = aws.seoul }

  cluster_id        = module.database.kor_db_cluster_id
  subnet_ids        = module.network.kor_private_db_subnet_ids
  security_group_id = module.database.proxy_kor_sg_id
  secret_arn        = module.database.kor_db_secret_arn
  iam_role_arn      = module.database.kor_proxy_role_arn
}

module "proxy_secondary_oregon" {
  source = "./modules/proxy/secondary"

  providers = { aws = aws.oregon }

  cluster_id        = module.database.usa_db_cluster_id
  subnet_ids        = module.network.usa_private_db_subnet_ids
  security_group_id = module.database.proxy_usa_sg_id
  secret_arn        = module.database.usa_db_secret_arn
  iam_role_arn      = module.database.usa_proxy_role_arn
}

module "dms" {
  count = var.dms_enabled ? 1 : 0
  source = "./modules/dms"

  providers = {
    aws.seoul  = aws.seoul
    aws.oregon = aws.oregon
  }

  db_username = var.db_username
  db_password = var.db_password
  db_kor_cluster_id = module.database.kor_cluster_id
  db_usa_cluster_id = module.database.usa_cluster_id
  dms_db_username = var.dms_db_username
  dms_db_password = var.dms_db_password

  source_db_endpoint = module.database.kor_db_cluster_endpoint
  target_db_endpoint = module.database.usa_db_cluster_endpoint

  source_db_sg_id = module.database.kor_db_security_group_id
  target_db_sg_id = module.database.usa_db_security_group_id

  db_port = module.database.db_port

  vpc_id     = module.network.kor_vpc_id
  subnet_ids = module.network.kor_private_db_subnet_ids

  source_db_name   = "kor_db"   
  target_db_name   = "usa_db"
  our_team = var.our_team

  onprem_db_endpoint = var.onprem_private_ip
  onprem_db_username = var.onprem_db_username
  onprem_db_password = var.onprem_db_password
  onprem_db_name     = "onprem_db"
  onprem_cidr = var.onprem_private_cidr
}


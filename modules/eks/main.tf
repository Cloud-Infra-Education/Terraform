# ================= Seoul Region ==================
module "eks_seoul" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = {
    aws = aws.seoul
  }

  cluster_name    = "y2om-formation-lap-seoul"
  cluster_version = "1.34"

  vpc_id     = var.kor_vpc_id
  subnet_ids = var.kor_private_eks_subnet_ids

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  eks_managed_node_groups = {
    standard-worker = {
      instance_types = ["t3.small"]
      desired_size   = 2
      min_size       = 2
      max_size       = 5

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                  = "true"
        "k8s.io/cluster-autoscaler/y2om-formation-lap-seoul" = "owned"
      }
    }
  }
}

module "cluster_autoscaler_irsa_seoul" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                        = "y2om-eks-autoscaler-irsa-seoul"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks_seoul.cluster_name]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks_seoul.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

# Helm 리소스는 02-kubernetes/helm.tf로 이동됨

# ================= Oregon Region ==================
module "eks_oregon" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = {
    aws = aws.oregon
  }

  cluster_name    = "y2om-formation-lap-oregon"
  cluster_version = "1.34"

  vpc_id     = var.usa_vpc_id
  subnet_ids = var.usa_private_eks_subnet_ids

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  eks_managed_node_groups = {
    standard-worker = {
      instance_types = ["t3.small"]
      desired_size   = 2
      min_size       = 2
      max_size       = 5

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                   = "true"
        "k8s.io/cluster-autoscaler/y2om-formation-lap-oregon" = "owned"
      }
    }
  }
}

module "cluster_autoscaler_irsa_oregon" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                        = "y2om-eks-autoscaler-irsa-oregon"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks_oregon.cluster_name]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks_oregon.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

# Helm 리소스는 02-kubernetes/helm.tf로 이동됨

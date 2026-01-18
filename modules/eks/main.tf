# ================= Seoul Region ==================
module "eks_seoul" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = {
    aws = aws.seoul
  }

#  cluster_name    = "formation-lap-seoul"
  cluster_name    = "chan-formation-lap-seoul"
  cluster_version = "1.34"

  vpc_id     = var.kor_vpc_id
  subnet_ids = var.kor_private_eks_subnet_ids

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  eks_managed_node_groups = {
    standard-worker = {
      instance_types = ["t3.large"]
      desired_size   = 3
      min_size       = 2
      max_size       = 10

      tags = {
        "k8s.io/cluster-autoscaler/enabled"                   = "true"
        "k8s.io/cluster-autoscaler/formation-lap-seoul" = "owned"
      }
    }
  }
}

module "cluster_autoscaler_irsa_seoul" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

#  role_name = "eks-autoscaler-irsa-seoul"
  role_name = "chan-eks-autoscaler-irsa-seoul"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks_seoul.cluster_name]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks_seoul.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "helm_release" "cluster_autoscaler_seoul" {
#  name       = "eks-autoscaler-seoul"
  name       = "chan-eks-autoscaler-seoul"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks_seoul.cluster_name
  }
  set {
    name  = "awsRegion"
    value = "ap-northeast-2"
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler_irsa_seoul.iam_role_arn
  }

  depends_on = [module.eks_seoul]
}

# ================= Oregon Region ==================
module "eks_oregon" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = {
    aws = aws.oregon
  }

#  cluster_name    = "formation-lap-oregon"
  cluster_name    = "chan-formation-lap-oregon"
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
        "k8s.io/cluster-autoscaler/enabled"              = "true"
        "k8s.io/cluster-autoscaler/formation-lap-oregon" = "owned"
      }
    }
  }
}

module "cluster_autoscaler_irsa_oregon" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

#  role_name = "eks-autoscaler-irsa-oregon"
  role_name = "chan-eks-autoscaler-irsa-oregon"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [module.eks_oregon.cluster_name]

  oidc_providers = {
    eks = {
      provider_arn               = module.eks_oregon.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "helm_release" "cluster_autoscaler_oregon" {
  provider   = helm.oregon
#  name       = "eks-autoscaler-oregon"
  name       = "chan-eks-autoscaler-oregon"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks_oregon.cluster_name
  }
  set {
    name  = "awsRegion"
    value = "us-west-2"
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.cluster_autoscaler_irsa_oregon.iam_role_arn
  }

  depends_on = [module.eks_oregon]
}

module "eks_seoul" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = {
    aws = aws.seoul
  }

  cluster_name    = "formation-lap-seoul1"
  cluster_version = "1.34"

  vpc_id     = var.kor_vpc_id
  subnet_ids = var.kor_private_eks_subnet_ids

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  cluster_encryption_config = {}

  eks_managed_node_groups = {
    standard-workers = {
      instance_types = ["t3.small"]
      desired_size   = 2
      min_size       = 2
      max_size       = 2
    }
  }
}


module "eks_oregon" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = {
    aws = aws.oregon
  }

  cluster_name    = "formation-lap-oregon1"
  cluster_version = "1.34"

  vpc_id     = var.usa_vpc_id
  subnet_ids = var.usa_private_eks_subnet_ids

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  cluster_encryption_config = {}

  eks_managed_node_groups = {
    standard-workers = {
      instance_types = ["t3.small"]
      desired_size   = 2
      min_size       = 2
      max_size       = 2
    }
  }
}

module "eks_seoul" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  providers = {
    aws = aws.seoul
  }

  cluster_name    = "formation-lap-seoul"
  cluster_version = "1.34"

  vpc_id     = module.kor_vpc.vpc_id
  subnet_ids = module.kor_vpc.private_subnet_ids

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs


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

  cluster_name    = "formation-lap-oregon"
  cluster_version = "1.34"

  vpc_id     = module.usa_vpc.vpc_id
  subnet_ids = module.usa_vpc.private_subnet_ids

  cluster_endpoint_private_access      = true
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.eks_public_access_cidrs

  eks_managed_node_groups = {
    standard-workers = {
      instance_types = ["t3.small"]
      desired_size   = 2
      min_size       = 2
      max_size       = 2
    }
  }
}

resource "aws_eks_access_entry" "terraform_admin" {
  provider      = aws.seoul
  cluster_name  = module.eks_seoul.cluster_name
  principal_arn = var.eks_admin_principal_arn
  type          = "STANDARD"
}
resource "aws_eks_access_policy_association" "terraform_admin_cluster" {
  cluster_name  = module.eks_seoul.cluster_name
  principal_arn = aws_eks_access_entry.terraform_admin.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}


resource "aws_eks_access_entry" "terraform_admin_oregon" {
  provider      = aws.oregon
  cluster_name  = module.eks_oregon.cluster_name
  principal_arn = var.eks_admin_principal_arn
  type          = "STANDARD"
}
resource "aws_eks_access_policy_association" "terraform_admin_cluster_oregon" {
  provider      = aws.oregon
  cluster_name  = module.eks_oregon.cluster_name
  principal_arn = aws_eks_access_entry.terraform_admin_oregon.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}

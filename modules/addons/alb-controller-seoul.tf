module "alb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "alb-controller-irsa"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = var.eks_seoul_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# 주의: 현재 서버에서 EKS 클러스터 접근이 안 되는 경우,
# ALB Controller는 나중에 수동으로 설치하거나
# EKS 클러스터에 접근 가능한 환경에서 설치하세요.
# 네트워크 연결 문제 해결 후 주석 해제

# resource "kubernetes_service_account_v1" "alb_controller" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#
#     annotations = {
#       "eks.amazonaws.com/role-arn" = module.alb_controller_irsa.iam_role_arn
#     }
#   }
# }
#
# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#
#   set {
#     name  = "clusterName"
#     value = var.eks_seoul_cluster_name
#   }
#
#   set {
#     name  = "region"
#     value = "ap-northeast-2"
#   }
#
#   set {
#     name  = "vpcId"
#     value = var.kor_vpc_id
#   }
#
#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }
#
#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }
#
#   depends_on = [
#     kubernetes_service_account_v1.alb_controller,
#     module.alb_controller_irsa
#   ]
#
#   timeout = 600
# }

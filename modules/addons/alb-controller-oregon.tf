module "alb_controller_irsa_oregon" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "y2om-alb-controller-irsa-oregon"

  attach_load_balancer_controller_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = var.eks_oregon_oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "kubernetes_service_account_v1" "alb_controller_oregon" {
  provider = kubernetes.oregon
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb_controller_irsa_oregon.iam_role_arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller_oregon" {
  provider = helm.oregon

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.eks_oregon_cluster_name
  }

  set {
    name  = "region"
    value = "us-west-2"
  }

  set {
    name  = "vpcId"
    value = var.usa_vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [
    kubernetes_service_account_v1.alb_controller_oregon,
    module.alb_controller_irsa_oregon
  ]

  timeout = 600
}

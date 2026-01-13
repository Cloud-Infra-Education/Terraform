# Helm 리소스는 별도 파일로 분리하여 EKS 클러스터 생성 후 적용
# providers.tf에서 Helm provider가 module.eks output을 참조하므로
# 이 파일은 클러스터가 생성된 후에만 적용됩니다

resource "helm_release" "cluster_autoscaler_seoul" {
  name       = "y2om-eks-autoscaler-seoul"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.seoul_cluster_name
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
    value = module.eks.seoul_cluster_autoscaler_irsa_role_arn
  }

  depends_on = [
    module.eks,
    time_sleep.wait_for_cluster_seoul
  ]
}

resource "helm_release" "cluster_autoscaler_oregon" {
  provider   = helm.oregon
  name       = "y2om-eks-autoscaler-oregon"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"
  version    = "9.37.0"

  set {
    name  = "autoDiscovery.clusterName"
    value = module.eks.oregon_cluster_name
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
    value = module.eks.oregon_cluster_autoscaler_irsa_role_arn
  }

  depends_on = [
    module.eks,
    time_sleep.wait_for_cluster_oregon
  ]
}

# EKS 클러스터가 완전히 준비될 때까지 대기
resource "time_sleep" "wait_for_cluster_seoul" {
  depends_on = [module.eks]
  create_duration = "60s"
}

resource "time_sleep" "wait_for_cluster_oregon" {
  depends_on = [module.eks]
  create_duration = "60s"
}

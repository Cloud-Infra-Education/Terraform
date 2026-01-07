locals {
  seoul_region = "ap-northeast-2"
  seoul_host   = "aps-workspaces.${local.seoul_region}.amazonaws.com"
  rw_sa_name   = "amp-remote-write-sa"
  q_sa_name    = "amp-query-proxy-sa"
}

# ------ 테라폼 관리형 네임스페이스------
resource "kubernetes_namespace_v1" "monitoring_seoul" {
  metadata { name = var.namespace }
}

# ------ AMP Workspace 생성 ------
resource "aws_prometheus_workspace" "seoul" {
  provider = aws.seoul
  alias    = var.amp_workspace_alias_seoul
}

# ------ Prometheus가 AMP에 remote_write 하도록 하는 정책 ------
resource "aws_iam_policy" "amp_remote_write_seoul" {
  provider    = aws.seoul
  name        = "AMPRemoteWrite-${aws_prometheus_workspace.seoul.id}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["aps:RemoteWrite"]
        Resource = aws_prometheus_workspace.seoul.arn
      }
    ]
  })
}

# ------ Grafana가 AMP를 Query(읽기)하도록 하는 정책 ------
resource "aws_iam_policy" "amp_query_seoul" {
  provider    = aws.seoul
  name        = "AMPQuery-${aws_prometheus_workspace.seoul.id}"
  description = "Query AMP from SigV4 proxy (Seoul)."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aps:QueryMetrics",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ]
        Resource = aws_prometheus_workspace.seoul.arn
      }
    ]
  })
}

# ------ IRSA용 AMP 쓰기용 IAM Role을 만든다람쥐 ------
module "amp_remote_write_irsa_seoul" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  providers = { aws = aws.seoul }
  role_name = "amp-remote-write-irsa-seoul"
  role_policy_arns = {
    amp_remote_write = aws_iam_policy.amp_remote_write_seoul.arn
  }
  oidc_providers = {
    eks = {
      provider_arn               = var.eks_seoul_oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${local.rw_sa_name}"]
    }
  }
}

# ------ 위에서 만든 IAM Role을 붙여서 IRSA를 만듬 ------ 
resource "kubernetes_service_account_v1" "amp_remote_write_sa_seoul" {
  metadata {
    name      = local.rw_sa_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.amp_remote_write_irsa_seoul.iam_role_arn
    }
  }
  depends_on = [kubernetes_namespace_v1.monitoring_seoul]
}

# ------ IRSA용 AMP 읽기(쿼리)용 IAM Role을 만든다 ------
module "amp_query_irsa_seoul" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  providers = { aws = aws.seoul }
  role_name = "amp-query-irsa-seoul"
  role_policy_arns = {
    amp_query = aws_iam_policy.amp_query_seoul.arn
  }
  oidc_providers = {
    eks = {
      provider_arn               = var.eks_seoul_oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${local.q_sa_name}"]
    }
  }
}

# ------ 위에서 만든 IAM Role을 붙여서 IRSA를 만듬 ------
resource "kubernetes_service_account_v1" "amp_query_sa_seoul" {
  metadata {
    name      = local.q_sa_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.amp_query_irsa_seoul.iam_role_arn
    }
  }
  depends_on = [kubernetes_namespace_v1.monitoring_seoul]
}

# ------  ------
resource "helm_release" "kps_seoul" {
  provider   = helm
  name       = "kps"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.namespace
  values = [
    yamlencode({
      grafana = { enabled = false }
      prometheus = {
        serviceAccount = { create = false, name = local.rw_sa_name }
        prometheusSpec = {
          containers = [
            {
              name  = "aws-sigv4-proxy"
              image = "public.ecr.aws/aws-observability/aws-sigv4-proxy:1.0"
              args  = ["--name","aps","--region",local.seoul_region,"--host",local.seoul_host,"--port","8005"]
              ports = [{ name = "sigv4-proxy", containerPort = 8005 }]
            }
          ]
          remoteWrite = [
            {
              url = "http://localhost:8005/workspaces/${aws_prometheus_workspace.seoul.id}/api/v1/remote_write"
            }
          ]
        }
      }
    })
  ]
  depends_on = [kubernetes_service_account_v1.amp_remote_write_sa_seoul]
  timeout    = 900
}

# ------  ------
resource "kubernetes_deployment_v1" "amp_sigv4_proxy_seoul" {
  metadata {
    name      = "amp-sigv4-proxy"
    namespace = var.namespace
    labels    = { app = "amp-sigv4-proxy" }
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "amp-sigv4-proxy" } }
    template {
      metadata { labels = { app = "amp-sigv4-proxy" } }
      spec {
        service_account_name = local.q_sa_name
        container {
          name  = "aws-sigv4-proxy"
          image = "public.ecr.aws/aws-observability/aws-sigv4-proxy:1.0"
          args  = ["--name","aps","--region",local.seoul_region,"--host",local.seoul_host,"--port","8005"]
          port { container_port = 8005 }
        }
      }
    }
  }
  depends_on = [kubernetes_service_account_v1.amp_query_sa_seoul]
}

# ------  ------
resource "kubernetes_service_v1" "amp_sigv4_proxy_seoul" {
  metadata {
    name      = "amp-sigv4-proxy"
    namespace = var.namespace
  }
  spec {
    selector = { app = "amp-sigv4-proxy" }
    port {
      name        = "http"
      port        = 8005
      target_port = 8005
    }
    type = "ClusterIP"
  }
  depends_on = [kubernetes_deployment_v1.amp_sigv4_proxy_seoul]
}

# ------  ------
resource "helm_release" "grafana_seoul" {
  provider   = helm
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = var.namespace
  values = [
    yamlencode({
      adminPassword = var.grafana_admin_password
      service = { type = "ClusterIP", port = 80 }
      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "AMP"
              type      = "prometheus"
              access    = "proxy"
              url       = "http://amp-sigv4-proxy.${var.namespace}:8005/workspaces/${aws_prometheus_workspace.seoul.id}"
              isDefault = true
            }
          ]
        }
      }
    })
  ]
  depends_on = [kubernetes_service_v1.amp_sigv4_proxy_seoul]
  timeout    = 900
}


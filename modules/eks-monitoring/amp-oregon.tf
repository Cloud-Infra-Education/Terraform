locals {
  oregon_region = "us-west-2"
  oregon_host   = "aps-workspaces.${local.oregon_region}.amazonaws.com"
  rw_sa_name_o  = "amp-remote-write-sa"
  q_sa_name_o   = "amp-query-proxy-sa"
}
resource "kubernetes_namespace_v1" "monitoring_oregon" {
  provider = kubernetes.oregon
  metadata { name = var.namespace }
}
resource "aws_prometheus_workspace" "oregon" {
  provider = aws.oregon
  alias    = var.amp_workspace_alias_oregon
}
resource "aws_iam_policy" "amp_remote_write_oregon" {
  provider    = aws.oregon
  name        = "AMPRemoteWrite-${aws_prometheus_workspace.oregon.id}"
  description = "Prometheus remote_write to AMP (Oregon)."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = ["aps:RemoteWrite"], Resource = aws_prometheus_workspace.oregon.arn }
    ]
  })
}
resource "aws_iam_policy" "amp_query_oregon" {
  provider    = aws.oregon
  name        = "AMPQuery-${aws_prometheus_workspace.oregon.id}"
  description = "Query AMP from SigV4 proxy (Oregon)."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["aps:QueryMetrics","aps:GetSeries","aps:GetLabels","aps:GetMetricMetadata"]
        Resource = aws_prometheus_workspace.oregon.arn
      }
    ]
  })
}
module "amp_remote_write_irsa_oregon" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  providers = { aws = aws.oregon }
  role_name = "amp-remote-write-irsa-oregon"
  role_policy_arns = {
    amp_remote_write = aws_iam_policy.amp_remote_write_oregon.arn
  }
  oidc_providers = {
    eks = {
      provider_arn               = var.eks_oregon_oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${local.rw_sa_name_o}"]
    }
  }
}
resource "kubernetes_service_account_v1" "amp_remote_write_sa_oregon" {
  provider = kubernetes.oregon
  metadata {
    name      = local.rw_sa_name_o
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.amp_remote_write_irsa_oregon.iam_role_arn
    }
  }
  depends_on = [kubernetes_namespace_v1.monitoring_oregon]
}
module "amp_query_irsa_oregon" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"
  providers = { aws = aws.oregon }
  role_name = "amp-query-irsa-oregon"
  role_policy_arns = {
    amp_query = aws_iam_policy.amp_query_oregon.arn
  }
  oidc_providers = {
    eks = {
      provider_arn               = var.eks_oregon_oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${local.q_sa_name_o}"]
    }
  }
}
resource "kubernetes_service_account_v1" "amp_query_sa_oregon" {
  provider = kubernetes.oregon
  metadata {
    name      = local.q_sa_name_o
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = module.amp_query_irsa_oregon.iam_role_arn
    }
  }
  depends_on = [kubernetes_namespace_v1.monitoring_oregon]
}
resource "helm_release" "kps_oregon" {
  provider   = helm.oregon
  name       = "kps"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = var.namespace
  values = [
    yamlencode({
      grafana = { enabled = false }
      prometheus = {
        serviceAccount = { create = false, name = local.rw_sa_name_o }
        prometheusSpec = {
          containers = [
            {
              name  = "aws-sigv4-proxy"
              image = "public.ecr.aws/aws-observability/aws-sigv4-proxy:1.0"
              args  = ["--name","aps","--region",local.oregon_region,"--host",local.oregon_host,"--port","8005"]
              ports = [{ name = "sigv4-proxy", containerPort = 8005 }]
            }
          ]
          remoteWrite = [
            { url = "http://localhost:8005/workspaces/${aws_prometheus_workspace.oregon.id}/api/v1/remote_write" }
          ]
        }
      }
    })
  ]
  depends_on = [kubernetes_service_account_v1.amp_remote_write_sa_oregon]
  timeout    = 900
}
resource "kubernetes_deployment_v1" "amp_sigv4_proxy_oregon" {
  provider = kubernetes.oregon
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
        service_account_name = local.q_sa_name_o
        container {
          name  = "aws-sigv4-proxy"
          image = "public.ecr.aws/aws-observability/aws-sigv4-proxy:1.0"
          args  = ["--name","aps","--region",local.oregon_region,"--host",local.oregon_host,"--port","8005"]
          port { container_port = 8005 }
        }
      }
    }
  }
  depends_on = [kubernetes_service_account_v1.amp_query_sa_oregon]
}
resource "kubernetes_service_v1" "amp_sigv4_proxy_oregon" {
  provider = kubernetes.oregon
  metadata {
    name      = "amp-sigv4-proxy"
    namespace = var.namespace
  }
  spec {
    selector = { app = "amp-sigv4-proxy" }
    port { 
      name = "http"
      port = 8005
      target_port = 8005 
    }
    type = "ClusterIP"
  }
  depends_on = [kubernetes_deployment_v1.amp_sigv4_proxy_oregon]
}
resource "helm_release" "grafana_oregon" {
  provider   = helm.oregon
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
              url       = "http://amp-sigv4-proxy.${var.namespace}:8005/workspaces/${aws_prometheus_workspace.oregon.id}"
              isDefault = true
            }
          ]
        }
      }
    })
  ]
  depends_on = [kubernetes_service_v1.amp_sigv4_proxy_oregon]
  timeout    = 900
}


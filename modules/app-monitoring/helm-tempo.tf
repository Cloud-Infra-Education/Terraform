# ==============================
# Layer 3 - Tempo (Helm)
# ==============================

resource "helm_release" "tempo_seoul" {
  name      = local.releases.tempo
  namespace = var.namespace

  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo-distributed"
  version    = var.tempo_chart_version

  create_namespace = false

  values = [
    yamlencode({
      # Keep predictable service names (used by locals.tempo_otlp_grpc_endpoint).
      fullnameOverride = local.releases.tempo

      # We use S3 via IRSA, so disable bundled MinIO.
      minio = {
        enabled = false
      }

      # IRSA on a single SA, and let all components use it.
      serviceAccount = {
        create = true
        name   = local.service_accounts.tempo
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.tempo_seoul.arn
        }
      }

      # Minimal ingestion receiver for the next step (Alloy / app exporters).
      traces = {
        otlp = {
          grpc = {
            enabled = true
          }
          http = {
            enabled = false
          }
        }
      }

      # Minimal config: multi-tenancy on, S3 backend.
      # Tempo enforces tenancy via X-Scope-OrgID.
      tempo = {
        structuredConfig = {
          multitenancy_enabled = true
        }
      }

      storage = {
        trace = {
          backend = "s3"
          s3 = {
            bucket   = module.s3_tempo.bucket_name
            endpoint = "s3.${var.region}.amazonaws.com"
            region   = var.region
            insecure = false
          }
        }
      }

      # Keep it minimal for the first install.
      gateway = {
        enabled = false
      }

      metricsGenerator = {
        enabled = false
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring,
    aws_iam_role_policy_attachment.tempo_s3_seoul,
  ]
}


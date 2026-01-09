# ==============================
# Layer 3 - Loki (Helm)
# ==============================

resource "helm_release" "loki_seoul" {
  name      = local.releases.loki
  namespace = var.namespace

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  version    = var.loki_chart_version

  create_namespace = false

  values = [
    yamlencode({
      deploymentMode    = "SimpleScalable"
      fullnameOverride  = local.releases.loki

      loki = {
        auth_enabled = true

        serviceAccount = {
          create = true
          name   = local.service_accounts.loki
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.loki_seoul.arn
          }
        }

        ingester = {
          max_chunk_age     = "2m"
          chunk_idle_period = "1m"
          chunk_target_size = 524288
          wal = {
            checkpoint_duration = "1m"
          }
        }

        storage = {
          type = "s3"
          bucketNames = {
            chunks = module.s3_loki.bucket_name
            ruler  = module.s3_loki.bucket_name
            admin  = module.s3_loki.bucket_name
          }
          s3 = {
            region = var.region
          }
        }

        schemaConfig = {
          configs = [
            {
              from         = "2024-01-01"
              store        = "tsdb"
              object_store = "s3"
              schema       = "v13"
              index = {
                prefix = "loki_index_"
                period = "24h"
              }
            }
          ]
        }
      }

      chunksCache = {
        enabled         = true
        allocatedMemory = 512
        resources = {
          requests = {
            cpu    = "100m"
            memory = "512Mi"
          }
          limits = {
            memory = "1Gi"
          }
        }
      }

      write = {
        serviceAccount = {
          name = local.service_accounts.loki
        }
        persistence = {
          storageClass = kubernetes_storage_class_v1.loki_wal_seoul.metadata[0].name
          size         = var.loki_wal_size
        }
      }

      read = {
        serviceAccount = {
          name = local.service_accounts.loki
        }
        persistence = {
          storageClass = kubernetes_storage_class_v1.loki_wal_seoul.metadata[0].name
          size         = var.loki_wal_size
        }
      }

      backend = {
        serviceAccount = {
          name = local.service_accounts.loki
        }
        persistence = {
          storageClass = kubernetes_storage_class_v1.loki_wal_seoul.metadata[0].name
          size         = var.loki_wal_size
        }
      }

      lokiCanary = {
        enabled = true
        pushUrl = "http://loki-write.${var.namespace}.svc.cluster.local:3100/loki/api/v1/push"
      }

    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring,
    aws_eks_addon.ebs_csi_driver,
    kubernetes_storage_class_v1.loki_wal_seoul,
    aws_iam_role_policy_attachment.loki_s3_seoul,
  ]
}


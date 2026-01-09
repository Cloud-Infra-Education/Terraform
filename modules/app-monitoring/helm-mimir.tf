# ==============================
# Layer 3 - Mimir (Helm)
# ==============================

resource "helm_release" "mimir_seoul" {
  name      = local.releases.mimir
  namespace = var.namespace

  repository = "https://grafana.github.io/helm-charts"
  chart      = "mimir-distributed"
  version    = var.mimir_chart_version

  create_namespace = false

  values = [
    yamlencode({
      fullnameOverride = local.releases.mimir

      # We use S3 via IRSA, so disable bundled MinIO.
      minio = {
        enabled = false
      }

      # IRSA on a single SA, and pin each component to use it.
      serviceAccount = {
        create = true
        name   = local.service_accounts.mimir
        annotations = {
          "eks.amazonaws.com/role-arn" = aws_iam_role.mimir_seoul.arn
        }
      }

      mimir = {
        structuredConfig = {
#         auth_enabled = true

#          auth = {
#            multitenancy_enabled = true
#          }

          common = {
            storage = {
              backend = "s3"
              s3 = {
                endpoint    = "s3.${var.region}.amazonaws.com"
                region      = var.region
                insecure    = false
                bucket_name = module.s3_mimir_blocks.bucket_name
              }
            }
          }

          blocks_storage = {
            storage_prefix = "blocks"
            backend        = "s3"
            s3 = {
              endpoint    = "s3.${var.region}.amazonaws.com"
              region      = var.region
              insecure    = false
              bucket_name = module.s3_mimir_blocks.bucket_name
            }
            tsdb = {
              dir = "/data/mimir/tsdb"
            }
          }

          alertmanager_storage = {
            storage_prefix = "alertmanager"
            backend        = "s3"
            s3 = {
              endpoint    = "s3.${var.region}.amazonaws.com"
              region      = var.region
              insecure    = false
              bucket_name = module.s3_mimir_alertmanager.bucket_name
            }
          }

          ruler_storage = {
            storage_prefix = "ruler"
            backend        = "s3"
            s3 = {
              endpoint    = "s3.${var.region}.amazonaws.com"
              region      = var.region
              insecure    = false
              bucket_name = module.s3_mimir_ruler.bucket_name
            }
          }

          compactor = {
            data_dir = "/data/mimir/compactor"
          }
        }
      }

      # ---- ServiceAccount pinning (IRSA) ----
      ingester = {
        serviceAccount = {
          create = false
          name   = local.service_accounts.mimir
        }
        persistentVolume = {
          enabled      = true
          storageClass = kubernetes_storage_class_v1.mimir_gp3_seoul.metadata[0].name
        }
      }

      distributor = {
        serviceAccount = {
          create = false
          name   = local.service_accounts.mimir
        }
      }

      compactor = {
        serviceAccount = {
          create = false
          name   = local.service_accounts.mimir
        }
        persistentVolume = {
          enabled      = true
          storageClass = kubernetes_storage_class_v1.mimir_gp3_seoul.metadata[0].name
        }
      }

      querier = {
        serviceAccount = {
          create = false
          name   = local.service_accounts.mimir
        }
      }

      store_gateway = {
        serviceAccount = {
          create = false
          name   = local.service_accounts.mimir
        }
        persistentVolume = {
          enabled      = true
          storageClass = kubernetes_storage_class_v1.mimir_gp3_seoul.metadata[0].name
        }
      }

      alertmanager = {
        serviceAccount = {
          create = false
          name   = local.service_accounts.mimir
        }
        persistentVolume = {
          enabled      = true
          storageClass = kubernetes_storage_class_v1.mimir_gp3_seoul.metadata[0].name
        }
      }

      ruler = {
        serviceAccount = {
          create = false
          name   = local.service_accounts.mimir
        }
        persistentVolume = {
          enabled      = true
          storageClass = kubernetes_storage_class_v1.mimir_gp3_seoul.metadata[0].name
        }
      }
    })
  ]

  depends_on = [
    kubernetes_namespace_v1.monitoring,
    aws_eks_addon.ebs_csi_driver,
    kubernetes_storage_class_v1.mimir_gp3_seoul,
    aws_iam_role_policy_attachment.mimir_s3_seoul,
  ]
}


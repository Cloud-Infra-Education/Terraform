# ==============================
# Layer 2 - Persistence (Loki WAL)
# ==============================

resource "kubernetes_storage_class_v1" "loki_wal_seoul" {
  metadata {
    name = var.loki_wal_storageclass_name
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    "csi.storage.k8s.io/fstype" = "ext4"
    encrypted = "true"
  }
}


# ==============================
# Layer 2 - Persistence (Mimir)
# ==============================

resource "kubernetes_storage_class_v1" "mimir_gp3_seoul" {
  metadata {
    name = var.mimir_storageclass_name
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type                        = "gp3"
    "csi.storage.k8s.io/fstype" = "ext4"
    encrypted                   = "true"
  }
}


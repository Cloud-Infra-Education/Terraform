#!/bin/bash

terraform state rm module.eks.helm_release.cluster_autoscaler_seoul
terraform state rm module.eks.helm_release.cluster_autoscaler_oregon

terraform destroy -auto-approve


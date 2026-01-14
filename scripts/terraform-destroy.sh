#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

STACKS=(
  "10-app-monitoring"
#  "09-"
  "08-domain-ga"
  "07-domain-cf"
  "06-certificate"
  "05-argocd"
  "04-addons"
  "03-database"
  "02-kubernetes"
  "01-infra"
)

for s in "${STACKS[@]}"; do
  printf "\n========== DESTROY: %s ==========\n" "$s"
  (
    cd "${ROOT_DIR}/${s}"
    terraform init

    if [[ "$s" == "10-app-monitoring" ]]; then
      kubectl delete pod -n app-monitoring-seoul loki-write-{0..2} || true 
    fi

    if [[ "$s" == "02-kubernetes" ]]; then
      terraform state rm module.eks.helm_release.cluster_autoscaler_oregon || true
      terraform state rm module.eks.helm_release.cluster_autoscaler_seoul  || true
    fi

    terraform destroy -auto-approve
  )
done


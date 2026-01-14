#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

STACKS=(
  "01-infra"
  #"02-kubernetes"
  "03-database"
  #"04-addons"
  #"05-argocd"
  #"06-certificate"
  #"07-domain-cf"
  #"08-domain-ga"
)

for s in "${STACKS[@]}"; do
  echo "========== APPLY: $s =========="
  (
    cd "${ROOT_DIR}/${s}"
    terraform init
    terraform apply -auto-approve
  )
done

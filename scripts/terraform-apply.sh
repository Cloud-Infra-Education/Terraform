#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

STACKS=(
  "01-infra"
  "02-kubernetes"
  "03-database"
  "04-addons"
  "05-argocd"
  "06-certificate"
  "07-domain-cf"
  "08-domain-ga"
# "09-"
  "10-app-monitoring"
)

for s in "${STACKS[@]}"; do
  echo "========== APPLY: $s =========="
  (
    cd "${ROOT_DIR}/${s}"

    # 02-kubernetes 디렉터리인 경우 예외 처리
    if [[ "$s" == "05-argocd" ]]; then
      echo "Running custom script for $s..."
      ./terraform-apply.sh
    else
      # 그 외의 디렉터리는 표준 테라폼 명령어 실행
      terraform init
      terraform apply -auto-approve
    fi
  )
done

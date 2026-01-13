#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ArgoCD까지만 구축하려면 아래 주석을 해제하고, 전체 구축하려면 원래대로 복원하세요
# STACKS=(
#   "01-infra"
#   "02-kubernetes"
#   "03-database"
#   "04-addons"
#   "05-argocd"
# )

# 전체 스택 (기본값)
STACKS=(
  "01-infra"
  "02-kubernetes"
  "03-database"
  "04-addons"
  "05-argocd"
  "06-certificate"
  "07-domain-cf"
  "08-domain-ga"
  "09-domain-access-logs"
)

for s in "${STACKS[@]}"; do
  echo "========== APPLY: $s =========="
  (
    set +e
    cd "${ROOT_DIR}/${s}"
    terraform init
    terraform apply -var-file="${ROOT_DIR}/terraform.tfvars" -auto-approve
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "⚠️  Warning: Apply failed for $s (exit code: $EXIT_CODE), but continuing to next stack..."
    fi
    exit 0
  )
  echo ""
done

echo "========== 스크립트 실행 완료 =========="

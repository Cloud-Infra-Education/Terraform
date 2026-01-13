#!/usr/bin/env bash
set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 스택을 역순으로 destroy (의존성 순서 고려)
STACKS=(
  "09-domain-access-logs"
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
  echo "========== DESTROY: $s =========="
  (
    set +e
    cd "${ROOT_DIR}/${s}"
    terraform init
    terraform destroy -var-file="${ROOT_DIR}/terraform.tfvars" -auto-approve
    EXIT_CODE=$?
    if [ $EXIT_CODE -ne 0 ]; then
      echo "⚠️  Warning: Destroy failed for $s (exit code: $EXIT_CODE), but continuing to next stack..."
    fi
    exit 0
  )
  echo ""
done

echo "========== Destroy 스크립트 실행 완료 =========="

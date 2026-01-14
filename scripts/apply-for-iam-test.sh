#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "========== Step 1: Apply 01-infra (Network, S3) =========="
cd "${ROOT_DIR}/01-infra"
terraform init
# remote state가 없어도 network와 s3는 생성 가능하도록 try() 사용
terraform apply -var="our_team=team-formation-lap" -auto-approve || {
  echo "Warning: 01-infra apply에 일부 에러가 있을 수 있지만 계속 진행합니다..."
}

echo ""
echo "========== Step 2: Apply 02-kubernetes (EKS, ECR) =========="
cd "${ROOT_DIR}/02-kubernetes"
terraform init
terraform apply -auto-approve

echo ""
echo "========== Step 3: Apply 03-database (DB, Lambda SG) =========="
cd "${ROOT_DIR}/03-database"
terraform init
terraform apply -auto-approve

echo ""
echo "========== Step 4: Apply 01-infra again (IAM Role) =========="
cd "${ROOT_DIR}/01-infra"
terraform plan -var="our_team=team-formation-lap" | grep -E "(aws_iam|Plan:)" || true
terraform apply -var="our_team=team-formation-lap" -auto-approve

echo ""
echo "========== 완료! IAM 역할이 생성되었습니다 =========="

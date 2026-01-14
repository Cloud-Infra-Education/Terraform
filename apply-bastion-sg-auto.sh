#!/bin/bash

# 자동으로 Terraform apply 실행 (확인 없이)

set -e

cd /root/Terraform

echo "=========================================="
echo "Terraform Apply - Bastion 보안 그룹 규칙"
echo "=========================================="
echo ""

# Terraform 초기화
echo "1. Terraform 초기화..."
terraform init -upgrade > /dev/null 2>&1 || terraform init
echo "   ✅ 완료"
echo ""

# Terraform 검증
echo "2. Terraform 설정 검증..."
if ! terraform validate; then
    echo "   ❌ 검증 실패"
    exit 1
fi
echo "   ✅ 검증 성공"
echo ""

# Plan 실행
echo "3. 변경사항 확인..."
terraform plan -out=tfplan
PLAN_EXIT_CODE=$?

if [ $PLAN_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ Terraform plan 실패"
    exit 1
fi

echo ""
echo "4. Terraform apply 실행..."
terraform apply tfplan

APPLY_EXIT_CODE=$?

if [ $APPLY_EXIT_CODE -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ Terraform apply 성공!"
    echo "=========================================="
    echo ""
    echo "Bastion Public IP:"
    terraform output -json 2>/dev/null | jq -r '.kor_bastion_public_ip.value // "N/A"' || echo "출력 확인 필요"
    echo ""
else
    echo ""
    echo "❌ Terraform apply 실패"
    exit 1
fi

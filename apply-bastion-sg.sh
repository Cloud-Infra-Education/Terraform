#!/bin/bash

# Bastion 보안 그룹 규칙 추가를 위한 Terraform Apply 스크립트

set -e

echo "=========================================="
echo "Terraform Apply - Bastion 보안 그룹 규칙 추가"
echo "=========================================="
echo ""

# 현재 디렉토리 확인
if [ ! -f "main.tf" ]; then
    echo "❌ Error: main.tf 파일을 찾을 수 없습니다."
    echo "   /root/Terraform 디렉토리에서 실행하세요."
    exit 1
fi

# Terraform 초기화 (필요한 경우)
echo "1. Terraform 초기화 확인..."
terraform init -upgrade > /dev/null 2>&1 || terraform init
echo "   ✅ 완료"
echo ""

# Terraform 검증
echo "2. Terraform 설정 검증..."
if terraform validate; then
    echo "   ✅ 검증 성공"
else
    echo "   ❌ 검증 실패"
    exit 1
fi
echo ""

# Plan 실행
echo "3. 변경사항 확인 (terraform plan)..."
echo "   (계속하려면 Enter를 누르세요)"
read -r

terraform plan -out=tfplan
PLAN_EXIT_CODE=$?

if [ $PLAN_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ Terraform plan 실패"
    exit 1
fi

echo ""
echo "=========================================="
echo "변경사항 요약"
echo "=========================================="
echo ""
echo "예상 변경사항:"
echo "  - Bastion 보안 그룹 ID 출력 추가"
echo "  - RDS Proxy 보안 그룹에 Bastion 인바운드 규칙 추가"
echo "    * Seoul 리전: Bastion → RDS Proxy (포트 3306)"
echo "    * Oregon 리전: Bastion → RDS Proxy (포트 3306)"
echo ""
echo "=========================================="
echo "적용 확인"
echo "=========================================="
echo ""
echo "Terraform apply를 실행하시겠습니까? (yes/no)"
read -r CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "취소되었습니다."
    exit 0
fi

# Apply 실행
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
    echo "다음 단계:"
    echo "1. Bastion Public IP 확인:"
    echo "   terraform output -json | jq -r '.kor_bastion_public_ip.value'"
    echo ""
    echo "2. Bastion에 SSH 접속하여 Backend 실행"
    echo "   자세한 내용은 VPC_BACKEND_SETUP.md 참고"
    echo ""
else
    echo ""
    echo "❌ Terraform apply 실패 (exit code: $APPLY_EXIT_CODE)"
    exit 1
fi

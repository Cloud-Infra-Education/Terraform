#!/bin/bash

# 01-infra 스택을 먼저 적용하여 Bastion 출력 추가
# 그 다음 03-database 스택 적용

set -e

echo "=========================================="
echo "1단계: 01-infra 스택 적용"
echo "=========================================="
echo ""

cd /root/Terraform/01-infra

# 1. Terraform 초기화
echo "1. Terraform 초기화..."
terraform init -upgrade
echo "   ✅ 완료"
echo ""

# 2. Terraform 검증
echo "2. Terraform 설정 검증..."
if terraform validate; then
    echo "   ✅ 검증 성공"
else
    echo "   ❌ 검증 실패"
    exit 1
fi
echo ""

# 3. Plan 실행
echo "3. 변경사항 확인..."
terraform plan -var-file="../terraform.tfvars" -out=tfplan
PLAN_EXIT_CODE=$?

if [ $PLAN_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ Terraform plan 실패"
    exit 1
fi

echo ""
echo "4. Terraform apply 실행..."
terraform apply tfplan

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 01-infra 스택 적용 완료!"
    echo ""
else
    echo ""
    echo "❌ 01-infra 스택 적용 실패"
    exit 1
fi

echo ""
echo "=========================================="
echo "2단계: 03-database 스택 적용"
echo "=========================================="
echo ""

cd /root/Terraform/03-database

# 1. Terraform 초기화
echo "1. Terraform 초기화..."
terraform init -upgrade
echo "   ✅ 완료"
echo ""

# 2. Terraform 검증
echo "2. Terraform 설정 검증..."
if terraform validate; then
    echo "   ✅ 검증 성공"
else
    echo "   ❌ 검증 실패"
    exit 1
fi
echo ""

# 3. Plan 실행
echo "3. 변경사항 확인..."
terraform plan -var-file="../terraform.tfvars" -out=tfplan
PLAN_EXIT_CODE=$?

if [ $PLAN_EXIT_CODE -ne 0 ]; then
    echo ""
    echo "❌ Terraform plan 실패"
    exit 1
fi

echo ""
echo "4. Terraform apply 실행..."
terraform apply tfplan

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✅ 모든 스택 적용 완료!"
    echo "=========================================="
    echo ""
    echo "다음 단계:"
    echo "1. Bastion Public IP 확인:"
    echo "   cd /root/Terraform/01-infra"
    echo "   terraform output -json | jq -r '.kor_bastion_public_ip.value'"
    echo ""
    echo "2. Bastion에 SSH 접속하여 Backend 실행"
    echo "   자세한 내용은 VPC_BACKEND_SETUP.md 참고"
    echo ""
else
    echo ""
    echo "❌ 03-database 스택 적용 실패"
    exit 1
fi

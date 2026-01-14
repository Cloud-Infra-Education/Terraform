#!/bin/bash
# Bastion IAM 역할에 S3 권한 추가

echo "============================================================"
echo "Bastion IAM 역할에 S3 권한 추가"
echo "============================================================"
echo ""

cd /root/Terraform/01-infra

echo "1. Terraform 초기화..."
terraform init -upgrade

echo ""
echo "2. 변경사항 확인..."
terraform plan -var-file="../terraform.tfvars"

echo ""
echo "3. Terraform 적용..."
terraform apply -var-file="../terraform.tfvars" -auto-approve

echo ""
echo "✅ S3 권한 추가 완료!"
echo ""
echo "이제 다시 코드 전송을 시도하세요:"
echo "  cd /root/Terraform"
echo "  python3 transfer_via_s3.py"

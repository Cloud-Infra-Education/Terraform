#!/bin/bash
# Bastion IAM 역할 추가를 위한 Terraform 적용

echo "============================================================"
echo "Bastion IAM 역할 추가 (EC2 Instance Connect용)"
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
echo "주의: 기존 인스턴스에 IAM 역할을 추가하려면 인스턴스를 재시작해야 할 수 있습니다."
read -p "계속하시겠습니까? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "취소되었습니다."
    exit 0
fi

terraform apply -var-file="../terraform.tfvars"

echo ""
echo "============================================================"
echo "적용 완료!"
echo "============================================================"
echo ""
echo "다음 단계:"
echo "1. 인스턴스 재시작 (필요시):"
echo "   aws ec2 reboot-instances --instance-ids i-0088889a043f54312 --region ap-northeast-2"
echo ""
echo "2. IAM 역할 확인:"
echo "   aws ec2 describe-instances --region ap-northeast-2 --instance-ids i-0088889a043f54312 --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' --output text"
echo ""
echo "3. EC2 Instance Connect 다시 시도"

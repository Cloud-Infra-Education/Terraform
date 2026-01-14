#!/bin/bash
# Bastion 보안 그룹에 현재 IP 추가 (임시 해결책)

echo "============================================================"
echo "Bastion 보안 그룹 수정"
echo "============================================================"
echo ""

# 현재 IP 확인
CURRENT_IP=$(curl -s https://checkip.amazonaws.com)
echo "현재 IP: $CURRENT_IP"
echo ""

# Instance ID 확인
INSTANCE_ID="i-0088889a043f54312"
echo "Instance ID: $INSTANCE_ID"
echo ""

# 보안 그룹 ID 확인
SG_ID=$(aws ec2 describe-instances \
  --region ap-northeast-2 \
  --instance-ids $INSTANCE_ID \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
  --output text)

echo "보안 그룹 ID: $SG_ID"
echo ""

# 보안 그룹에 현재 IP 추가
echo "보안 그룹에 현재 IP 추가 중..."
aws ec2 authorize-security-group-ingress \
  --region ap-northeast-2 \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr $CURRENT_IP/32 \
  --description "Temporary access for EC2 Instance Connect"

if [ $? -eq 0 ]; then
    echo "✅ 보안 그룹 규칙 추가 완료!"
    echo ""
    echo "이제 EC2 Instance Connect를 다시 시도해보세요."
else
    echo "❌ 보안 그룹 규칙 추가 실패"
    echo "이미 규칙이 존재할 수 있습니다."
fi

echo ""
echo "보안 그룹 규칙 확인:"
aws ec2 describe-security-groups \
  --region ap-northeast-2 \
  --group-ids $SG_ID \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`22`]' \
  --output table

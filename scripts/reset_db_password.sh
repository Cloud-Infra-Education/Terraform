#!/bin/bash
# DB 클러스터 비밀번호 리셋 스크립트

echo "=== DB 클러스터 비밀번호 리셋 ==="
echo ""

CLUSTER_ID="y2om-kor-aurora-mysql"
REGION="ap-northeast-2"
PASSWORD="StrongPassword123!"

echo "클러스터 ID: $CLUSTER_ID"
echo "리전: $REGION"
echo "새 비밀번호: $PASSWORD"
echo ""

read -p "비밀번호를 리셋하시겠습니까? (y/n): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "취소되었습니다."
    exit 1
fi

echo "비밀번호 리셋 중..."
aws rds modify-db-cluster \
  --region $REGION \
  --db-cluster-identifier $CLUSTER_ID \
  --master-user-password "$PASSWORD" \
  --apply-immediately

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 비밀번호 리셋 요청이 성공했습니다."
    echo ""
    echo "클러스터 상태 확인 중..."
    aws rds describe-db-clusters \
      --region $REGION \
      --db-cluster-identifier $CLUSTER_ID \
      --query 'DBClusters[0].{Status:Status,MasterUsername:MasterUsername}' \
      --output table
    
    echo ""
    echo "⚠️  비밀번호 변경은 몇 분 소요될 수 있습니다."
    echo "   클러스터 상태가 'available'이 될 때까지 대기하세요."
else
    echo "❌ 비밀번호 리셋 실패"
    exit 1
fi

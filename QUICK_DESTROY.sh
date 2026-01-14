#!/bin/bash
# 빠른 인프라 Destroy 스크립트

set -e

echo "=========================================="
echo "인프라 Destroy 시작"
echo "=========================================="
echo ""
echo "⚠️  주의: 모든 인프라가 삭제됩니다!"
echo ""
read -p "계속하시겠습니까? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "취소되었습니다."
    exit 0
fi

# S3 버킷 확인 및 비우기
echo ""
echo "=========================================="
echo "1. S3 버킷 확인"
echo "=========================================="

# 버킷 이름 찾기
BUCKET_NAME=$(aws s3 ls | grep -i "formation\|yuh\|origin" | awk '{print $3}' | head -1)

if [ -n "$BUCKET_NAME" ]; then
    echo "버킷 발견: $BUCKET_NAME"
    FILE_COUNT=$(aws s3 ls s3://$BUCKET_NAME/ --recursive 2>/dev/null | wc -l)
    echo "파일 개수: $FILE_COUNT"
    
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo "⚠️  버킷에 파일이 있습니다. 비우시겠습니까?"
        read -p "버킷 비우기 (yes/no): " empty_bucket
        if [ "$empty_bucket" = "yes" ]; then
            echo "버킷 비우는 중..."
            aws s3 rm s3://$BUCKET_NAME/ --recursive
            echo "✅ 버킷 비우기 완료"
        fi
    fi
else
    echo "⚠️  버킷을 찾을 수 없습니다. 계속 진행합니다."
fi

# Terraform Destroy
echo ""
echo "=========================================="
echo "2. Terraform Destroy 시작"
echo "=========================================="

cd /root/Terraform

STACKS=(
  "10-app-monitoring"
  "08-domain-ga"
  "07-domain-cf"
  "06-certificate"
  "05-argocd"
  "04-addons"
  "03-database"
  "02-kubernetes"
  "01-infra"
)

for stack in "${STACKS[@]}"; do
    if [ -d "$stack" ]; then
        echo ""
        echo "=========================================="
        echo "Destroy: $stack"
        echo "=========================================="
        
        cd "$stack"
        
        # 특수 처리
        if [ "$stack" == "10-app-monitoring" ]; then
            echo "특수 리소스 처리 중..."
            kubectl delete pod -n app-monitoring-seoul loki-write-{0..2} 2>/dev/null || true
        fi
        
        if [ "$stack" == "02-kubernetes" ]; then
            echo "Helm releases 제거 중..."
            terraform state rm module.eks.helm_release.cluster_autoscaler_oregon 2>/dev/null || true
            terraform state rm module.eks.helm_release.cluster_autoscaler_seoul 2>/dev/null || true
        fi
        
        terraform init -upgrade > /dev/null 2>&1
        terraform destroy -auto-approve
        
        cd ..
    else
        echo "⚠️  $stack 디렉토리가 없습니다. 건너뜁니다."
    fi
done

echo ""
echo "=========================================="
echo "✅ Destroy 완료!"
echo "=========================================="
echo ""
echo "다시 배포할 때:"
echo "  cd /root/Terraform"
echo "  ./scripts/terraform-apply.sh"
echo ""

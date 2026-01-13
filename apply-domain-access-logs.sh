#!/usr/bin/env bash
set -euo pipefail

# Domain Access Logs 적용 스크립트
cd "$(dirname "$0")/domain-access-logs"

# Route53 Zone ID (자동으로 가져오기)
ZONE_ID=$(aws route53 list-hosted-zones --query 'HostedZones[?Name==`matchacake.click.`].Id' --output text | sed 's|/hostedzone/||')

if [ -z "$ZONE_ID" ]; then
    echo "Error: Route53 Zone ID를 찾을 수 없습니다."
    exit 1
fi

echo "Route53 Zone ID: $ZONE_ID"
echo "Terraform 적용을 시작합니다..."

# Terraform 초기화 (필요한 경우)
terraform init

# Terraform 적용
terraform apply -var="route53_zone_id=$ZONE_ID" -auto-approve

echo ""
echo "=========================================="
echo "Domain Access Logs 적용 완료!"
echo "=========================================="
echo ""
echo "Output 정보:"
terraform output
echo ""
echo "테스트 가이드는 ../domain-access-logs-test-guide.md 를 참조하세요."

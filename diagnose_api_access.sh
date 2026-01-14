#!/bin/bash

echo "=========================================="
echo "API 접근 문제 진단 스크립트"
echo "=========================================="
echo ""

echo "1. Route53 호스팅 존 확인"
echo "----------------------------------------"
ZONE_ID=$(aws route53 list-hosted-zones --query "HostedZones[?Name=='matchacake.click.'].Id" --output text | cut -d'/' -f3)
if [ -z "$ZONE_ID" ]; then
    echo "❌ Route53 호스팅 존을 찾을 수 없습니다."
else
    echo "✅ 호스팅 존 ID: $ZONE_ID"
fi
echo ""

echo "2. api.matchacake.click Route53 레코드 확인"
echo "----------------------------------------"
RECORD=$(aws route53 list-resource-record-sets --hosted-zone-id $ZONE_ID --query "ResourceRecordSets[?Name=='api.matchacake.click.']" --output json 2>/dev/null)
if [ "$RECORD" == "[]" ] || [ -z "$RECORD" ]; then
    echo "❌ api.matchacake.click A 레코드가 존재하지 않습니다."
else
    echo "✅ Route53 레코드 존재:"
    echo "$RECORD" | jq .
fi
echo ""

echo "3. DNS 조회 테스트"
echo "----------------------------------------"
DNS_RESULT=$(dig +short api.matchacake.click 2>&1)
if [ -z "$DNS_RESULT" ]; then
    echo "❌ DNS 조회 실패: 레코드가 없거나 전파되지 않았습니다."
else
    echo "✅ DNS 조회 결과: $DNS_RESULT"
fi
echo ""

echo "4. ALB 상태 확인 (Seoul)"
echo "----------------------------------------"
ALB_SEOUL=$(aws elbv2 describe-load-balancers --region ap-northeast-2 --query "LoadBalancers[?contains(LoadBalancerName, 'matchacake-alb-test-seoul')]" --output json 2>/dev/null)
if [ "$ALB_SEOUL" == "[]" ] || [ -z "$ALB_SEOUL" ]; then
    echo "❌ Seoul ALB를 찾을 수 없습니다."
else
    ALB_DNS=$(echo "$ALB_SEOUL" | jq -r '.[0].DNSName')
    ALB_STATE=$(echo "$ALB_SEOUL" | jq -r '.[0].State.Code')
    echo "✅ ALB DNS: $ALB_DNS"
    echo "✅ ALB 상태: $ALB_STATE"
fi
echo ""

echo "5. ALB 상태 확인 (Oregon)"
echo "----------------------------------------"
ALB_OREGON=$(aws elbv2 describe-load-balancers --region us-west-2 --query "LoadBalancers[?contains(LoadBalancerName, 'matchacake-alb-test-oregon')]" --output json 2>/dev/null)
if [ "$ALB_OREGON" == "[]" ] || [ -z "$ALB_OREGON" ]; then
    echo "❌ Oregon ALB를 찾을 수 없습니다."
else
    ALB_DNS=$(echo "$ALB_OREGON" | jq -r '.[0].DNSName')
    ALB_STATE=$(echo "$ALB_OREGON" | jq -r '.[0].State.Code')
    echo "✅ ALB DNS: $ALB_DNS"
    echo "✅ ALB 상태: $ALB_STATE"
fi
echo ""

echo "6. Global Accelerator 확인 (us-east-1)"
echo "----------------------------------------"
GA_LIST=$(aws globalaccelerator list-accelerators --region us-east-1 --query "Accelerators[?contains(Name, 'formation-lap')]" --output json 2>/dev/null)
if [ "$GA_LIST" == "[]" ] || [ -z "$GA_LIST" ]; then
    echo "❌ Global Accelerator를 찾을 수 없습니다."
else
    echo "✅ Global Accelerator 존재:"
    echo "$GA_LIST" | jq -r '.[] | "  - \(.Name): \(.Status)"'
fi
echo ""

echo "7. 08-domain-ga Terraform State 확인"
echo "----------------------------------------"
if [ -f "/root/Terraform/08-domain-ga/terraform.tfstate" ]; then
    STATE_COUNT=$(cd /root/Terraform/08-domain-ga && terraform state list 2>/dev/null | wc -l)
    if [ "$STATE_COUNT" -eq 0 ]; then
        echo "❌ Terraform state가 비어있습니다. Global Accelerator가 배포되지 않았습니다."
    else
        echo "✅ Terraform state에 $STATE_COUNT 개의 리소스가 있습니다:"
        cd /root/Terraform/08-domain-ga && terraform state list 2>/dev/null | head -10
    fi
else
    echo "❌ terraform.tfstate 파일이 없습니다."
fi
echo ""

echo "8. Ingress 상태 확인"
echo "----------------------------------------"
if command -v kubectl &> /dev/null; then
    INGRESS=$(kubectl get ingress -n formation-lap msa-ingress -o json 2>/dev/null)
    if [ -z "$INGRESS" ]; then
        echo "❌ Ingress를 찾을 수 없습니다."
    else
        echo "✅ Ingress 존재"
        ADDRESS=$(echo "$INGRESS" | jq -r '.status.loadBalancer.ingress[0].hostname // "없음"')
        echo "   주소: $ADDRESS"
    fi
else
    echo "⚠️  kubectl이 설치되지 않았습니다."
fi
echo ""

echo "=========================================="
echo "진단 완료"
echo "=========================================="

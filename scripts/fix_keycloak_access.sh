#!/bin/bash
# Keycloak 접근 문제 해결 스크립트

set -e

echo "=== Keycloak 접근 문제 해결 ==="
echo ""

# 1. Keycloak Pod 상태 확인
echo "1. Keycloak Pod 상태 확인..."
kubectl get pods -n formation-lap -l app=keycloak

# 2. Keycloak Service 확인
echo ""
echo "2. Keycloak Service 확인..."
kubectl get svc -n formation-lap keycloak-service

# 3. Keycloak Ingress 확인
echo ""
echo "3. Keycloak Ingress 확인..."
kubectl get ingress -n formation-lap keycloak-ingress

# 4. ALB DNS 확인
echo ""
echo "4. ALB DNS 확인..."
ALB_DNS=$(kubectl get ingress -n formation-lap keycloak-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "")
if [ -z "$ALB_DNS" ]; then
    echo "⚠️  ALB DNS를 찾을 수 없습니다. Ingress가 생성되지 않았을 수 있습니다."
    echo "   Terraform을 적용하여 Ingress를 생성하세요."
else
    echo "✅ ALB DNS: $ALB_DNS"
fi

# 5. Route53 레코드 확인
echo ""
echo "5. Route53 레코드 확인..."
DOMAIN_NAME=$(terraform output -raw domain_name 2>/dev/null || echo "matchacake.click")
KEYCLOAK_DOMAIN="keycloak.${DOMAIN_NAME}"
echo "Keycloak 도메인: $KEYCLOAK_DOMAIN"

# 6. Keycloak 접근 테스트
echo ""
echo "6. Keycloak 접근 테스트..."
if [ -n "$ALB_DNS" ]; then
    echo "   HTTP 접근 테스트:"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://${ALB_DNS}/health" || echo "000")
    if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ] || [ "$HTTP_STATUS" = "404" ]; then
        echo "   ✅ HTTP 접근 가능 (상태 코드: $HTTP_STATUS)"
    else
        echo "   ⚠️  HTTP 접근 불가 (상태 코드: $HTTP_STATUS)"
    fi
    
    echo "   HTTPS 접근 테스트:"
    HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 -k "https://${ALB_DNS}/health" || echo "000")
    if [ "$HTTPS_STATUS" = "200" ] || [ "$HTTPS_STATUS" = "302" ] || [ "$HTTPS_STATUS" = "404" ]; then
        echo "   ✅ HTTPS 접근 가능 (상태 코드: $HTTPS_STATUS)"
    else
        echo "   ⚠️  HTTPS 접근 불가 (상태 코드: $HTTPS_STATUS)"
    fi
fi

# 7. 도메인 접근 테스트
echo ""
echo "7. 도메인 접근 테스트..."
if [ -n "$KEYCLOAK_DOMAIN" ]; then
    echo "   HTTP 접근 테스트:"
    DOMAIN_HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "http://${KEYCLOAK_DOMAIN}/health" || echo "000")
    if [ "$DOMAIN_HTTP_STATUS" = "200" ] || [ "$DOMAIN_HTTP_STATUS" = "302" ] || [ "$DOMAIN_HTTP_STATUS" = "404" ]; then
        echo "   ✅ HTTP 접근 가능 (상태 코드: $DOMAIN_HTTP_STATUS)"
    else
        echo "   ⚠️  HTTP 접근 불가 (상태 코드: $DOMAIN_HTTP_STATUS)"
    fi
    
    echo "   HTTPS 접근 테스트:"
    DOMAIN_HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 -k "https://${KEYCLOAK_DOMAIN}/health" || echo "000")
    if [ "$DOMAIN_HTTPS_STATUS" = "200" ] || [ "$DOMAIN_HTTPS_STATUS" = "302" ] || [ "$DOMAIN_HTTPS_STATUS" = "404" ]; then
        echo "   ✅ HTTPS 접근 가능 (상태 코드: $DOMAIN_HTTPS_STATUS)"
    else
        echo "   ⚠️  HTTPS 접근 불가 (상태 코드: $DOMAIN_HTTPS_STATUS)"
    fi
fi

# 8. Keycloak Pod 로그 확인
echo ""
echo "8. Keycloak Pod 로그 (최근 20줄)..."
kubectl logs -n formation-lap -l app=keycloak --tail=20

echo ""
echo "=== 완료 ==="
echo ""
echo "다음 단계:"
echo "1. ALB DNS가 없으면: terraform apply -target=module.domain.kubernetes_manifest.keycloak_ingress_seoul"
echo "2. Route53 레코드가 없으면: terraform apply -target=module.domain.aws_route53_record.keycloak_a"
echo "3. Keycloak Realm 및 Client 생성: python3 /root/Terraform/setup_keycloak_realm.py"

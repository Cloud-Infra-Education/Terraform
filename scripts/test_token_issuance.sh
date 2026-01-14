#!/bin/bash
# 토큰 발급 테스트 스크립트

echo "=== Backend API 토큰 발급 테스트 ==="
echo ""

# API URL 확인
INGRESS_HOST=$(kubectl get ingress -n formation-lap msa-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ -n "$INGRESS_HOST" ]; then
    API_URL="https://$INGRESS_HOST"
    echo "✅ Ingress ALB 사용: $API_URL"
else
    API_URL="http://localhost:8000"
    echo "⚠️  포트 포워딩 사용: $API_URL"
    echo "포트 포워딩 시작 중..."
    kubectl port-forward -n formation-lap svc/backend-api-service 8000:8000 > /dev/null 2>&1 &
    sleep 3
fi

echo ""
echo "=== 1. Health Check ==="
HEALTH=$(curl -s -k ${API_URL}/api/v1/health 2>&1)
echo "$HEALTH"
echo ""

# Keycloak 설정 확인
echo "=== 2. Keycloak 설정 확인 ==="
KEYCLOAK_URL=$(kubectl get configmap -n formation-lap backend-config -o jsonpath='{.data.KEYCLOAK_URL}' 2>/dev/null)
KEYCLOAK_REALM=$(kubectl get configmap -n formation-lap backend-config -o jsonpath='{.data.KEYCLOAK_REALM}' 2>/dev/null)
echo "Keycloak URL: $KEYCLOAK_URL"
echo "Keycloak Realm: $KEYCLOAK_REALM"
echo ""

# 테스트 사용자 정보
TEST_EMAIL="testuser@example.com"
TEST_PASSWORD="test12345"

echo "=== 3. 회원가입 테스트 ==="
echo "이메일: $TEST_EMAIL"
REGISTER_RESPONSE=$(curl -X POST ${API_URL}/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\",
    \"region_code\": \"KR\",
    \"subscription_status\": \"free\"
  }" \
  -k -s -w "\nHTTP_STATUS:%{http_code}" 2>&1)

HTTP_STATUS=$(echo "$REGISTER_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
BODY=$(echo "$REGISTER_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "201" ]; then
    echo "✅ 회원가입 성공"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
else
    echo "⚠️  회원가입 응답 (HTTP $HTTP_STATUS):"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
    if [ "$HTTP_STATUS" = "409" ]; then
        echo "이미 등록된 사용자입니다. 로그인을 시도합니다."
    fi
fi
echo ""

echo "=== 4. 로그인 및 토큰 발급 테스트 ==="
echo "이메일: $TEST_EMAIL"
LOGIN_RESPONSE=$(curl -X POST ${API_URL}/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\"
  }" \
  -k -s -w "\nHTTP_STATUS:%{http_code}" 2>&1)

HTTP_STATUS=$(echo "$LOGIN_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
BODY=$(echo "$LOGIN_RESPONSE" | sed '/HTTP_STATUS/d')

if [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ 로그인 성공!"
    echo ""
    echo "토큰 정보:"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
    echo ""
    
    # 토큰 추출
    ACCESS_TOKEN=$(echo "$BODY" | jq -r '.access_token' 2>/dev/null)
    if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ]; then
        echo "✅ 액세스 토큰 발급 성공!"
        echo "토큰 (처음 50자): ${ACCESS_TOKEN:0:50}..."
        echo ""
        echo "토큰을 사용하여 인증이 필요한 API를 호출할 수 있습니다:"
        echo "curl -H \"Authorization: Bearer $ACCESS_TOKEN\" ${API_URL}/api/v1/..."
    fi
else
    echo "❌ 로그인 실패 (HTTP $HTTP_STATUS)"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
fi
echo ""

echo "=== 5. Keycloak 직접 토큰 발급 테스트 ==="
if [ -n "$KEYCLOAK_URL" ]; then
    echo "Keycloak에 직접 토큰 요청..."
    KEYCLOAK_RESPONSE=$(curl -X POST ${KEYCLOAK_URL}/realms/${KEYCLOAK_REALM}/protocol/openid-connect/token \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=password&client_id=backend-client&username=$TEST_EMAIL&password=$TEST_PASSWORD" \
      -k -s -w "\nHTTP_STATUS:%{http_code}" 2>&1)
    
    KEYCLOAK_HTTP_STATUS=$(echo "$KEYCLOAK_RESPONSE" | grep "HTTP_STATUS" | cut -d: -f2)
    KEYCLOAK_BODY=$(echo "$KEYCLOAK_RESPONSE" | sed '/HTTP_STATUS/d')
    
    if [ "$KEYCLOAK_HTTP_STATUS" = "200" ]; then
        echo "✅ Keycloak 직접 토큰 발급 성공!"
        echo "$KEYCLOAK_BODY" | jq . 2>/dev/null || echo "$KEYCLOAK_BODY"
    else
        echo "⚠️  Keycloak 직접 토큰 발급 실패 (HTTP $KEYCLOAK_HTTP_STATUS)"
        echo "$KEYCLOAK_BODY" | jq . 2>/dev/null || echo "$KEYCLOAK_BODY"
    fi
else
    echo "⚠️  Keycloak URL을 찾을 수 없습니다"
fi

echo ""
echo "=== 테스트 완료 ==="

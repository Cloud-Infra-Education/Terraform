#!/bin/bash
echo "=== Backend API 토큰 발급 테스트 ==="
echo ""

# 포트 포워딩 시작
kubectl port-forward -n formation-lap svc/backend-api-service 8000:8000 > /dev/null 2>&1 &
sleep 3

API_URL="http://localhost:8000"
TEST_EMAIL="testuser$(date +%s)@example.com"
TEST_PASSWORD="test12345"

echo "1. 회원가입"
REGISTER=$(curl -s -X POST ${API_URL}/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\",
    \"region_code\": \"KR\",
    \"subscription_status\": \"free\"
  }")

echo "$REGISTER" | jq . 2>/dev/null || echo "$REGISTER"
echo ""

echo "2. 로그인 및 토큰 발급"
LOGIN=$(curl -s -X POST ${API_URL}/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{
    \"email\": \"$TEST_EMAIL\",
    \"password\": \"$TEST_PASSWORD\"
  }")

echo "$LOGIN" | jq . 2>/dev/null || echo "$LOGIN"
echo ""

ACCESS_TOKEN=$(echo "$LOGIN" | jq -r '.access_token' 2>/dev/null)
if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ]; then
    echo "✅ 토큰 발급 성공!"
    echo "토큰: ${ACCESS_TOKEN:0:100}..."
    echo ""
    echo "이 토큰을 사용하여 인증이 필요한 API를 호출할 수 있습니다:"
    echo "curl -H \"Authorization: Bearer $ACCESS_TOKEN\" ${API_URL}/api/v1/..."
else
    echo "❌ 토큰 발급 실패"
fi

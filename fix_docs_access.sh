#!/bin/bash

echo "=========================================="
echo "FastAPI /docs 경로 접근 문제 해결"
echo "=========================================="
echo ""

echo "1. 현재 Ingress 경로 확인"
echo "----------------------------------------"
kubectl get ingress -n formation-lap msa-ingress -o jsonpath='{.spec.rules[0].http.paths[*].path}' 2>&1
echo ""
echo ""

echo "2. 백엔드 파드에서 직접 테스트"
echo "----------------------------------------"
POD_NAME=$(kubectl get pods -n formation-lap -l app=backend-api -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$POD_NAME" ]; then
    echo "파드 이름: $POD_NAME"
    echo "백엔드 서비스 내부 접근 테스트:"
    kubectl run -it --rm test-curl --image=curlimages/curl:latest --restart=Never -- curl -s http://backend-api-service:8000/docs 2>&1 | head -20 || echo "테스트 실패"
else
    echo "❌ 백엔드 파드를 찾을 수 없습니다."
fi
echo ""

echo "3. 가능한 경로 테스트"
echo "----------------------------------------"
for path in "/docs" "/api/docs" "/api/v1/docs" "/openapi.json" "/api/openapi.json"; do
    echo -n "테스트: https://api.matchacake.click$path -> "
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "https://api.matchacake.click$path" 2>&1)
    echo "$STATUS"
done
echo ""

echo "=========================================="
echo "진단 완료"
echo "=========================================="

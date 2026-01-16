#!/bin/bash
# RDS Proxy 연결 진단 스크립트

echo "=== RDS Proxy 연결 진단 ==="
echo ""

# 1. RDS Proxy 상태 확인
echo "1. RDS Proxy 상태 확인..."
PROXY_NAME="y2om-formation-lap-kor-rds-proxy"
PROXY_ENDPOINT=$(aws rds describe-db-proxies --region ap-northeast-2 \
  --db-proxy-name $PROXY_NAME \
  --query 'DBProxies[0].Endpoint' --output text)

PROXY_STATUS=$(aws rds describe-db-proxies --region ap-northeast-2 \
  --db-proxy-name $PROXY_NAME \
  --query 'DBProxies[0].Status' --output text)

echo "   Proxy Name: $PROXY_NAME"
echo "   Endpoint: $PROXY_ENDPOINT"
echo "   Status: $PROXY_STATUS"
echo ""

# 2. RDS Proxy Target 상태 확인
echo "2. RDS Proxy Target 상태 확인..."
aws rds describe-db-proxy-targets --region ap-northeast-2 \
  --db-proxy-name $PROXY_NAME \
  --query 'Targets[*].{Type:Type,Status:TargetHealth.State,Endpoint:RdsEndpoint.Address}' \
  --output table
echo ""

# 3. 보안 그룹 확인
echo "3. 보안 그룹 확인..."
PROXY_SG=$(aws rds describe-db-proxies --region ap-northeast-2 \
  --db-proxy-name $PROXY_NAME \
  --query 'DBProxies[0].VpcSecurityGroupIds[0]' --output text)

EKS_NODE_SG=$(aws ec2 describe-instances --region ap-northeast-2 \
  --filters "Name=tag:eks:cluster-name,Values=y2om-formation-lap-seoul" "Name=instance-state-name,Values=running" \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text)

echo "   RDS Proxy SG: $PROXY_SG"
echo "   EKS Node SG: $EKS_NODE_SG"
echo ""

# 4. 보안 그룹 규칙 확인
echo "4. 보안 그룹 인바운드 규칙 확인..."
aws ec2 describe-security-groups --region ap-northeast-2 \
  --group-ids $PROXY_SG \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`3306`].{Port:FromPort,Protocol:IpProtocol,SourceSG:UserIdGroupPairs[0].GroupId}' \
  --output table
echo ""

# 5. 파드에서 연결 테스트
echo "5. 파드에서 연결 테스트..."
POD_NAME=$(kubectl get pods -n formation-lap -l app=backend-api -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POD_NAME" ]; then
    echo "   Pod: $POD_NAME"
    kubectl exec -n formation-lap $POD_NAME -- python3 -c "
import socket
import sys
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5)
    result = sock.connect_ex(('$PROXY_ENDPOINT', 3306))
    sock.close()
    if result == 0:
        print('   ✅ Port 3306 is OPEN (연결 가능)')
    else:
        print(f'   ❌ Port 3306 is CLOSED (error code: {result})')
        print('   ⚠️  보안 그룹 규칙을 확인하세요')
except Exception as e:
    print(f'   ❌ Connection error: {e}')
" 2>&1
else
    echo "   ⚠️  Backend API 파드를 찾을 수 없습니다"
fi
echo ""

# 6. 환경 변수 확인
echo "6. 환경 변수 확인..."
if [ -n "$POD_NAME" ]; then
    echo "   DATABASE_URL (처음 80자만 표시):"
    kubectl exec -n formation-lap $POD_NAME -- env | grep DATABASE_URL | sed 's/\(.\{80\}\).*/\1.../'
fi
echo ""

echo "=== 진단 완료 ==="
echo ""
echo "문제 해결 방법:"
echo "1. RDS Proxy 상태가 'available'인지 확인"
echo "2. RDS Proxy Target 상태가 'AVAILABLE'인지 확인"
echo "3. 보안 그룹 규칙이 올바르게 설정되어 있는지 확인"
echo "4. VPC 및 서브넷이 올바르게 설정되어 있는지 확인"

#!/bin/bash
# RDS Proxy 및 RDS Writer 연결 테스트 스크립트

set -e

echo "=== RDS Proxy TLS 연결 테스트 ==="
echo ""

# RDS Proxy 엔드포인트
PROXY_ENDPOINT=$(aws rds describe-db-proxies --region ap-northeast-2 --db-proxy-name y2om-formation-lap-kor-rds-proxy --query 'DBProxies[0].Endpoint' --output text)
echo "RDS Proxy 엔드포인트: $PROXY_ENDPOINT"
echo ""

# RDS Writer 엔드포인트
WRITER_ENDPOINT=$(aws rds describe-db-clusters --region ap-northeast-2 --db-cluster-identifier y2om-kor-aurora-mysql --query 'DBClusters[0].Endpoint' --output text)
echo "RDS Writer 엔드포인트: $WRITER_ENDPOINT"
echo ""

# 비밀번호 입력
read -sp "DB 비밀번호를 입력하세요 (기본값: StrongPassword123!): " DB_PASSWORD
DB_PASSWORD=${DB_PASSWORD:-StrongPassword123!}
echo ""

echo "=== 1. RDS Proxy 연결 테스트 (TLS 필수) ==="
echo "명령어: mysql -h $PROXY_ENDPOINT -u admin -p --ssl-mode=REQUIRED"
echo ""
mysql -h "$PROXY_ENDPOINT" -u admin -p"$DB_PASSWORD" --ssl-mode=REQUIRED -e "SELECT DATABASE(), USER(), VERSION(), NOW();" 2>&1 && echo "✅ RDS Proxy 연결 성공!" || echo "❌ RDS Proxy 연결 실패"

echo ""
echo "=== 2. RDS Writer 직접 연결 테스트 (TLS 선택) ==="
echo "명령어: mysql -h $WRITER_ENDPOINT -u admin -p"
echo ""
mysql -h "$WRITER_ENDPOINT" -u admin -p"$DB_PASSWORD" -e "SELECT DATABASE(), USER(), VERSION(), NOW();" 2>&1 && echo "✅ RDS Writer 연결 성공!" || echo "❌ RDS Writer 연결 실패"

echo ""
echo "=== 연결 테스트 완료 ==="

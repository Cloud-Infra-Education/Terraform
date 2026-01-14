#!/usr/bin/env python3
"""
모든 비밀번호 일치 확인 및 최종 진단
"""
import subprocess
import json

REGION = "ap-northeast-2"
CLUSTER_ID = "y2om-kor-aurora-mysql"
PROXY_NAME = "y2om-formation-lap-kor-rds-proxy"
SECRET_NAME = "formation-lap/db/dev/credentials"
EXPECTED_PASSWORD = "StrongPassword123!"

print("=" * 60)
print("비밀번호 일치 확인 및 최종 진단")
print("=" * 60)

# 1. Secrets Manager 비밀번호 확인
print("\n1단계: Secrets Manager 비밀번호 확인...")
cmd = [
    "aws", "secretsmanager", "get-secret-value",
    "--secret-id", SECRET_NAME,
    "--region", REGION,
    "--query", "SecretString",
    "--output", "text"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    secret_data = json.loads(result.stdout)
    sm_username = secret_data.get('username', '')
    sm_password = secret_data.get('password', '')
    
    print(f"✅ Username: {sm_username}")
    print(f"✅ Password: {sm_password}")
    
    if sm_password != EXPECTED_PASSWORD:
        print(f"\n⚠️  경고: Secrets Manager 비밀번호가 예상과 다릅니다!")
        print(f"   예상: {EXPECTED_PASSWORD}")
        print(f"   실제: {sm_password}")
    else:
        print(f"✅ Secrets Manager 비밀번호 일치")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 2. RDS Proxy가 Secrets Manager를 올바르게 읽는지 확인
print("\n2단계: RDS Proxy 설정 확인...")
cmd = [
    "aws", "rds", "describe-db-proxies",
    "--db-proxy-name", PROXY_NAME,
    "--region", REGION,
    "--query", "DBProxies[0].[Status,Auth[0].SecretArn]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    proxy_status = data[0]
    proxy_secret_arn = data[1]
    
    print(f"✅ Proxy 상태: {proxy_status}")
    print(f"✅ Proxy Secret ARN: {proxy_secret_arn}")
    
    # Secret ARN이 일치하는지 확인
    expected_arn = f"arn:aws:secretsmanager:{REGION}:404457776061:secret:{SECRET_NAME}-"
    if expected_arn in proxy_secret_arn:
        print(f"✅ Proxy가 올바른 Secret을 참조하고 있습니다")
    else:
        print(f"⚠️  경고: Proxy가 다른 Secret을 참조하고 있을 수 있습니다")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 3. RDS 클러스터 엔드포인트 확인 (직접 연결용)
print("\n3단계: RDS 클러스터 엔드포인트 확인...")
cmd = [
    "aws", "rds", "describe-db-clusters",
    "--db-cluster-identifier", CLUSTER_ID,
    "--region", REGION,
    "--query", "DBClusters[0].[Endpoint,ReaderEndpoint,Status]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    writer_endpoint = data[0]
    reader_endpoint = data[1]
    cluster_status = data[2]
    
    print(f"✅ Writer Endpoint: {writer_endpoint}")
    print(f"✅ Reader Endpoint: {reader_endpoint}")
    print(f"✅ Cluster Status: {cluster_status}")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

print("\n" + "=" * 60)
print("해결 방법:")
print("=" * 60)
print("RDS Proxy가 Secrets Manager를 읽었지만 여전히 연결이 실패하는 경우,")
print("다음 방법을 시도해보세요:")
print("\n1. RDS Proxy 연결 풀 초기화 (몇 분 더 대기)")
print("2. RDS 클러스터에 직접 연결 (Proxy 우회)")
print("   - 보안 그룹 수정 필요 (Bastion -> RDS 클러스터 직접 연결 허용)")
print(f"   - 엔드포인트: {writer_endpoint}")
print("\n3. Secrets Manager 비밀번호를 다시 업데이트 (강제로 Proxy가 다시 읽도록)")

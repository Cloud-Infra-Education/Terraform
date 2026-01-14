#!/usr/bin/env python3
"""
RDS 클러스터에 직접 연결 테스트 (Proxy 우회)
"""
import subprocess
import json

REGION = "ap-northeast-2"
CLUSTER_ID = "y2om-kor-aurora-mysql"

print("=" * 60)
print("RDS 클러스터 직접 연결 정보 확인")
print("=" * 60)

# RDS 클러스터 엔드포인트 확인
cmd = [
    "aws", "rds", "describe-db-clusters",
    "--db-cluster-identifier", CLUSTER_ID,
    "--region", REGION,
    "--query", "DBClusters[0].[Endpoint,ReaderEndpoint,Port,MasterUsername]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    endpoint = data[0]
    reader_endpoint = data[1]
    port = data[2]
    username = data[3]
    
    print(f"✅ Writer Endpoint: {endpoint}")
    print(f"✅ Reader Endpoint: {reader_endpoint}")
    print(f"✅ Port: {port}")
    print(f"✅ Master Username: {username}")
    
    print("\n" + "=" * 60)
    print("해결 방법:")
    print("=" * 60)
    print("RDS Proxy를 우회하고 RDS 클러스터에 직접 연결을 시도해보세요.")
    print("\n1. 보안 그룹 확인:")
    print("   - Bastion -> RDS 클러스터 직접 연결이 허용되어 있는지 확인")
    print("   - 현재는 Bastion -> RDS Proxy만 허용되어 있을 수 있음")
    print("\n2. .env 파일에서 직접 연결 시도:")
    print(f"   DATABASE_URL=mysql+pymysql://admin:StrongPassword123%21@{endpoint}:{port}/y2om_db")
    print("\n3. 또는 RDS Proxy가 Secrets Manager를 다시 읽도록 대기 (2-3분)")
    print("\n4. RDS Proxy 수정 (강제로 Secrets Manager 다시 읽기):")
    print("   - AWS 콘솔에서 RDS Proxy 수정")
    print("   - 또는 Terraform으로 RDS Proxy 재생성")
    
except Exception as e:
    print(f"❌ 확인 실패: {e}")

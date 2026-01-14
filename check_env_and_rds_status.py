#!/usr/bin/env python3
"""
.env 파일과 RDS 클러스터 상태 확인
"""
import subprocess
import json
import urllib.parse

REGION = "ap-northeast-2"
CLUSTER_ID = "y2om-kor-aurora-mysql"
PROXY_ENDPOINT = "y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com"

print("=" * 60)
print("환경 변수 및 RDS 상태 확인")
print("=" * 60)

# 1. RDS 클러스터 상태 확인
print("\n1단계: RDS 클러스터 상태 확인...")
cmd = [
    "aws", "rds", "describe-db-clusters",
    "--db-cluster-identifier", CLUSTER_ID,
    "--region", REGION,
    "--query", "DBClusters[0].[Status,PendingModifiedValues.MasterUserPassword]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    status = data[0]
    pending_password = data[1] if data[1] else None
    
    print(f"✅ 클러스터 상태: {status}")
    if pending_password:
        print(f"⚠️  비밀번호 변경 대기 중: {pending_password}")
        print(f"   비밀번호 변경이 완료될 때까지 기다려야 합니다.")
    else:
        print(f"✅ 비밀번호 변경 완료")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 2. Secrets Manager 확인
print("\n2단계: Secrets Manager 확인...")
cmd = [
    "aws", "secretsmanager", "get-secret-value",
    "--secret-id", "formation-lap/db/dev/credentials",
    "--region", REGION,
    "--query", "SecretString",
    "--output", "text"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    secret_data = json.loads(result.stdout)
    print(f"✅ Secrets Manager 비밀번호: {secret_data.get('password', 'N/A')[:10]}...")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 3. .env 파일 형식 확인 (Bastion에서 확인 필요)
print("\n3단계: .env 파일 확인 (Bastion에서 실행 필요)...")
print("\n다음 명령어를 Bastion에서 실행하세요:")
print("=" * 60)
print("cd /root/Backend")
print("echo '=== .env 파일 확인 ==='")
print("grep -E '^(DB_|DATABASE_)' .env")
print("")
print("echo '=== DATABASE_URL 확인 ==='")
print("grep 'DATABASE_URL' .env | sed 's/password=[^@]*/password=***/'")
print("")
print("echo '=== DB_PASSWORD 확인 ==='")
print("grep 'DB_PASSWORD' .env")
print("=" * 60)

# 4. 예상 DATABASE_URL 생성
print("\n4단계: 예상 DATABASE_URL 형식...")
expected_password = "StrongPassword123!"
encoded_password = urllib.parse.quote(expected_password, safe='')
expected_url = f"mysql+pymysql://admin:{encoded_password}@{PROXY_ENDPOINT}:3306/y2om_db"
print(f"예상 URL: mysql+pymysql://admin:***@{PROXY_ENDPOINT}:3306/y2om_db")
print(f"인코딩된 비밀번호: {encoded_password}")

print("\n" + "=" * 60)
print("다음 단계:")
print("=" * 60)
print("1. RDS 클러스터 비밀번호 변경이 완료될 때까지 대기 (보통 1-2분)")
print("2. Bastion에서 .env 파일 확인")
print("3. DATABASE_URL이 올바르게 설정되었는지 확인")
print("4. DB_PASSWORD가 'StrongPassword123!'인지 확인")

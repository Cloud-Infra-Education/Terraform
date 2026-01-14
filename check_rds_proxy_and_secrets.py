#!/usr/bin/env python3
"""
RDS Proxy와 Secrets Manager 상태 확인
"""
import subprocess
import json

REGION = "ap-northeast-2"
PROXY_NAME = "y2om-formation-lap-kor-rds-proxy"
SECRET_NAME = "formation-lap/db/dev/credentials"

print("=" * 60)
print("RDS Proxy와 Secrets Manager 상태 확인")
print("=" * 60)

# 1. RDS Proxy 정보 확인
print("\n1단계: RDS Proxy 정보 확인...")
cmd = [
    "aws", "rds", "describe-db-proxies",
    "--db-proxy-name", PROXY_NAME,
    "--region", REGION,
    "--query", "DBProxies[0].[Status,Auth[0].SecretArn,Auth[0].AuthScheme]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    status = data[0]
    secret_arn = data[1]
    auth_scheme = data[2]
    
    print(f"✅ Proxy 상태: {status}")
    print(f"✅ Secret ARN: {secret_arn}")
    print(f"✅ Auth Scheme: {auth_scheme}")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 2. Secrets Manager 비밀번호 확인
print("\n2단계: Secrets Manager 비밀번호 확인...")
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
    username = secret_data.get('username', '')
    password = secret_data.get('password', '')
    
    print(f"✅ Username: {username}")
    print(f"✅ Password: {password[:5]}...{password[-3:] if len(password) > 8 else ''}")
    print(f"   전체 비밀번호: {password}")
    
    if password != "StrongPassword123!":
        print(f"\n⚠️  경고: Secrets Manager 비밀번호가 예상과 다릅니다!")
        print(f"   예상: StrongPassword123!")
        print(f"   실제: {password}")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 3. RDS Proxy 타겟 상태 확인
print("\n3단계: RDS Proxy 타겟 상태 확인...")
cmd = [
    "aws", "rds", "describe-db-proxy-targets",
    "--db-proxy-name", PROXY_NAME,
    "--region", REGION,
    "--query", "Targets[0].[TargetStatus,Endpoint,Port]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    target_status = data[0]
    endpoint = data[1]
    port = data[2]
    
    print(f"✅ 타겟 상태: {target_status}")
    print(f"✅ 엔드포인트: {endpoint}")
    print(f"✅ 포트: {port}")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 4. RDS Proxy 재시작 방법 제안
print("\n" + "=" * 60)
print("해결 방법:")
print("=" * 60)
print("RDS Proxy는 Secrets Manager의 변경사항을 자동으로 감지하지만,")
print("때로는 몇 분이 걸릴 수 있습니다.")
print("\n다음 방법을 시도해보세요:")
print("\n1. RDS Proxy가 Secrets Manager를 다시 읽도록 대기 (2-3분)")
print("2. RDS Proxy를 수정하여 강제로 Secrets Manager를 다시 읽도록 함:")
print(f"   aws rds modify-db-proxy \\")
print(f"     --db-proxy-name {PROXY_NAME} \\")
print(f"     --region {REGION} \\")
print(f"     --auth SecretArn={secret_arn},AuthScheme=SECRETS \\")
print(f"     --no-apply-immediately")
print("\n3. 또는 RDS Proxy를 삭제하고 다시 생성 (Terraform으로)")
print("\n4. 또는 RDS 클러스터에 직접 연결 시도 (Proxy 우회):")
print("   - RDS 클러스터 엔드포인트로 직접 연결")
print("   - 보안 그룹에서 Bastion -> RDS 직접 연결 허용")

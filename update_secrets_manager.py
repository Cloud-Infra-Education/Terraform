#!/usr/bin/env python3
"""
Secrets Manager 비밀번호 업데이트
"""
import subprocess
import json

REGION = "ap-northeast-2"
SECRET_NAME = "formation-lap/db/dev/credentials"
DB_USERNAME = "admin"
DB_PASSWORD = "StrongPassword123!"  # terraform.tfvars에서 확인한 비밀번호

print("=" * 60)
print("Secrets Manager 비밀번호 업데이트")
print("=" * 60)

# Secrets Manager에 저장할 JSON 형식
secret_value = {
    "username": DB_USERNAME,
    "password": DB_PASSWORD
}

# 1. 현재 Secret 확인
print("\n1단계: 현재 Secret 확인...")
cmd = [
    "aws", "secretsmanager", "get-secret-value",
    "--secret-id", SECRET_NAME,
    "--region", REGION,
    "--query", "SecretString",
    "--output", "text"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    current_secret = json.loads(result.stdout.strip())
    print(f"✅ 현재 Secret 확인 성공")
    print(f"   Username: {current_secret.get('username', 'N/A')}")
    print(f"   Password: {'*' * len(current_secret.get('password', ''))}")
    
    if current_secret.get('password') == DB_PASSWORD:
        print(f"\n✅ 비밀번호가 이미 일치합니다!")
    else:
        print(f"\n⚠️  비밀번호가 일치하지 않습니다. 업데이트가 필요합니다.")
except subprocess.CalledProcessError as e:
    print(f"❌ Secret 확인 실패: {e.stderr}")
    print(f"   Secret이 존재하지 않을 수 있습니다.")
except Exception as e:
    print(f"❌ 오류: {e}")

# 2. Secret 업데이트
print("\n2단계: Secret 업데이트...")
cmd = [
    "aws", "secretsmanager", "put-secret-value",
    "--secret-id", SECRET_NAME,
    "--region", REGION,
    "--secret-string", json.dumps(secret_value),
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    print(f"✅ Secret 업데이트 성공!")
    print(f"   ARN: {json.loads(result.stdout).get('ARN', 'N/A')}")
except subprocess.CalledProcessError as e:
    print(f"❌ Secret 업데이트 실패: {e.stderr}")
    if "ResourceNotFoundException" in e.stderr:
        print(f"\n⚠️  Secret이 존재하지 않습니다. 생성이 필요합니다.")
        # Secret 생성 시도
        print("\n3단계: Secret 생성 시도...")
        cmd_create = [
            "aws", "secretsmanager", "create-secret",
            "--name", SECRET_NAME,
            "--region", REGION,
            "--secret-string", json.dumps(secret_value),
            "--output", "json"
        ]
        try:
            result = subprocess.run(cmd_create, capture_output=True, text=True, check=True)
            print(f"✅ Secret 생성 성공!")
            print(f"   ARN: {json.loads(result.stdout).get('ARN', 'N/A')}")
        except subprocess.CalledProcessError as e2:
            print(f"❌ Secret 생성 실패: {e2.stderr}")
    else:
        print(f"\n수동으로 업데이트하세요:")
        print(f"aws secretsmanager put-secret-value \\")
        print(f"  --secret-id {SECRET_NAME} \\")
        print(f"  --region {REGION} \\")
        print(f"  --secret-string '{json.dumps(secret_value)}'")
except Exception as e:
    print(f"❌ 오류: {e}")

print("\n" + "=" * 60)
print("완료!")
print("=" * 60)
print("\n이제 Backend에서 다시 연결을 시도하세요.")

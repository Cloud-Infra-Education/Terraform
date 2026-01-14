#!/usr/bin/env python3
"""
Secrets Manager 비밀번호 확인 및 수정
"""
import subprocess
import json

REGION = "ap-northeast-2"
SECRET_NAME = "formation-lap/db/dev/credentials"

print("=" * 60)
print("Secrets Manager 비밀번호 확인")
print("=" * 60)

# Secrets Manager에서 비밀번호 가져오기
cmd = [
    "aws", "secretsmanager", "get-secret-value",
    "--secret-id", SECRET_NAME,
    "--region", REGION,
    "--query", "SecretString",
    "--output", "text"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    secret_string = result.stdout.strip()
    secret_data = json.loads(secret_string)
    
    print(f"\n✅ Secrets Manager 비밀번호 확인 성공")
    print(f"Secret 이름: {SECRET_NAME}")
    print(f"Username: {secret_data.get('username', 'N/A')}")
    print(f"Password: {'*' * len(secret_data.get('password', ''))}")
    print(f"\n현재 .env 파일의 비밀번호와 일치하는지 확인하세요.")
    print(f"\n.env 파일의 DB_PASSWORD를 다음으로 설정하세요:")
    print(f"DB_PASSWORD={secret_data.get('password', '')}")
    
except subprocess.CalledProcessError as e:
    print(f"\n❌ Secrets Manager 접근 실패: {e.stderr}")
    print(f"\nSecrets Manager에 비밀번호를 생성하거나 업데이트해야 합니다.")
except json.JSONDecodeError as e:
    print(f"\n❌ JSON 파싱 실패: {e}")
    print(f"Secret String: {secret_string}")

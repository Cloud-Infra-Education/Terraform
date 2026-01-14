#!/usr/bin/env python3
"""
Keycloak Admin 설정 추가 및 확인
"""
import subprocess
import json
import re

REGION = "ap-northeast-2"
INSTANCE_ID = "i-0088889a043f54312"

print("=" * 60)
print("Keycloak Admin 설정 추가")
print("=" * 60)

# .env 파일에 Admin 설정 추가
python_script = """
import re

# .env 파일 읽기
with open('/root/Backend/.env', 'r') as f:
    content = f.read()

# KEYCLOAK_ADMIN_USERNAME과 KEYCLOAK_ADMIN_PASSWORD 확인
has_admin_username = re.search(r'^KEYCLOAK_ADMIN_USERNAME=', content, re.MULTILINE)
has_admin_password = re.search(r'^KEYCLOAK_ADMIN_PASSWORD=', content, re.MULTILINE)

print('=== 현재 Keycloak 설정 ===')
keycloak_lines = [line for line in content.split('\\n') if line.startswith('KEYCLOAK')]
for line in keycloak_lines:
    print(line)

if not has_admin_username:
    print('\\n✅ KEYCLOAK_ADMIN_USERNAME 추가 중...')
    content += '\\nKEYCLOAK_ADMIN_USERNAME=admin\\n'
else:
    print('\\n✅ KEYCLOAK_ADMIN_USERNAME 이미 존재')

if not has_admin_password:
    print('✅ KEYCLOAK_ADMIN_PASSWORD 추가 중...')
    content += 'KEYCLOAK_ADMIN_PASSWORD=admin\\n'
else:
    print('✅ KEYCLOAK_ADMIN_PASSWORD 이미 존재')

# .env 파일 쓰기
with open('/root/Backend/.env', 'w') as f:
    f.write(content)

print('\\n✅ .env 파일 업데이트 완료!')
print('\\n=== 업데이트된 Keycloak 설정 ===')
with open('/root/Backend/.env', 'r') as f:
    for line in f:
        if line.startswith('KEYCLOAK'):
            print(line.strip())
"""

commands = [
    "cd /root/Backend",
    "python3 <<'PYEOF'",
    python_script,
    "PYEOF"
]

cmd_ssm = [
    "aws", "ssm", "send-command",
    "--instance-ids", INSTANCE_ID,
    "--region", REGION,
    "--document-name", "AWS-RunShellScript",
    "--parameters", json.dumps({"commands": commands}),
    "--output", "text",
    "--query", "Command.CommandId"
]

print("\n명령어 실행 중...")
try:
    result = subprocess.run(cmd_ssm, capture_output=True, text=True, check=True)
    command_id = result.stdout.strip()
    print(f"Command ID: {command_id}")
    print("5초 대기 중...")
    import time
    time.sleep(5)
    
    # 결과 확인
    result_cmd = [
        "aws", "ssm", "get-command-invocation",
        "--command-id", command_id,
        "--instance-id", INSTANCE_ID,
        "--region", REGION,
        "--query", "[Status,StandardOutputContent,StandardErrorContent]",
        "--output", "json"
    ]
    
    result = subprocess.run(result_cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    status = data[0]
    output = data[1] if len(data) > 1 else ""
    error = data[2] if len(data) > 2 else ""
    
    print(f"\n상태: {status}")
    if output:
        print(f"\n출력:\n{output}")
    if error:
        print(f"\n오류:\n{error}")
    
    if status == "Success":
        print("\n" + "=" * 60)
        print("다음 단계:")
        print("=" * 60)
        print("\n1. Keycloak 서비스 접근 확인:")
        print("   - KEYCLOAK_URL이 'http://keycloak-service:8080'인데,")
        print("     이것이 Bastion에서 접근 가능한지 확인 필요")
        print("   - Keycloak이 Kubernetes에서 실행 중이라면,")
        print("     내부 서비스 이름으로 접근 가능해야 함")
        print("\n2. 서버 재시작:")
        print("   pkill -f uvicorn || true")
        print("   sleep 2")
        print("   nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &")
        print("\n3. Keycloak 연결 테스트:")
        print("   curl -s http://keycloak-service:8080/health || echo 'Keycloak 접근 불가'")
    
except Exception as e:
    print(f"❌ 오류: {e}")

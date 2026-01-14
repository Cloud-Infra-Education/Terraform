#!/usr/bin/env python3
"""
Bastion의 .env 파일에서 Keycloak 설정 확인 및 수정
"""
import subprocess
import json

REGION = "ap-northeast-2"
INSTANCE_ID = "i-0088889a043f54312"

print("=" * 60)
print("Keycloak 설정 확인 및 수정")
print("=" * 60)

# 1. 현재 .env 파일의 Keycloak 설정 확인
print("\n1단계: 현재 Keycloak 설정 확인...")
commands = [
    "cd /root/Backend",
    "echo '=== Keycloak 관련 환경 변수 ==='",
    "grep -E '^KEYCLOAK' .env || echo 'Keycloak 설정이 없습니다'"
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
    
    print("\n" + "=" * 60)
    print("Keycloak 설정 추가 방법:")
    print("=" * 60)
    print("\nSSM 접속 후 다음 명령어를 실행하세요:")
    print("\ncd /root/Backend")
    print("cat >> .env <<'EOF'")
    print("")
    print("# Keycloak 설정")
    print("KEYCLOAK_URL=http://keycloak.matchacake.click  # 또는 실제 Keycloak URL")
    print("KEYCLOAK_REALM=your-realm  # 실제 realm 이름")
    print("KEYCLOAK_CLIENT_ID=backend-client  # 또는 실제 client ID")
    print("KEYCLOAK_CLIENT_SECRET=your-client-secret  # client secret (있는 경우)")
    print("KEYCLOAK_ADMIN_USERNAME=admin  # Keycloak 관리자 사용자명")
    print("KEYCLOAK_ADMIN_PASSWORD=admin  # Keycloak 관리자 비밀번호")
    print("EOF")
    print("\n# 서버 재시작")
    print("pkill -f uvicorn || true")
    print("sleep 2")
    print("nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &")
    
except Exception as e:
    print(f"❌ 오류: {e}")

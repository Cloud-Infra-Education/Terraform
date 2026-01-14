#!/usr/bin/env python3
"""
전체 에러 로그 확인
"""
import subprocess
import json
import time

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"

def run_ssm(commands, desc, wait=30):
    print(f"\n{desc}...")
    cmd = [
        "aws", "ssm", "send-command",
        "--instance-ids", INSTANCE_ID, "--region", REGION,
        "--document-name", "AWS-RunShellScript",
        "--parameters", json.dumps({"commands": commands}),
        "--output", "text", "--query", "Command.CommandId"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    cmd_id = result.stdout.strip()
    print(f"Command ID: {cmd_id}, 대기 중... ({wait}초)")
    time.sleep(wait)
    
    result_cmd = [
        "aws", "ssm", "get-command-invocation",
        "--command-id", cmd_id, "--instance-id", INSTANCE_ID,
        "--region", REGION,
        "--query", "[Status,StandardOutputContent,StandardErrorContent]",
        "--output", "json"
    ]
    result = subprocess.run(result_cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    status = data[0]
    output = data[1] if len(data) > 1 else ""
    error = data[2] if len(data) > 2 else ""
    
    print(f"상태: {status}")
    print("=" * 60)
    print("출력:")
    print(output)
    print("=" * 60)
    if error:
        print("오류:")
        print(error)
        print("=" * 60)
    return status == "Success", output, error

print("=" * 60)
print("전체 에러 로그 확인")
print("=" * 60)

# 1. 서버 로그 전체 확인
commands1 = [
    "cd ~/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "cat server.log 2>/dev/null | tail -100 || echo '로그 파일 없음'"
]

run_ssm(commands1, "1단계: 서버 로그 확인", 20)

# 2. Python import 테스트 (단계별)
commands2 = [
    "cd ~/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "echo '=== config import ==='",
    "python3 -c 'from app.core.config import settings; print(\"OK\")' 2>&1",
    "echo ''",
    "echo '=== main.py import 테스트 ==='",
    "python3 -c 'import sys; sys.path.insert(0, \".\"); from app.api.v1.routes import health' 2>&1",
    "echo ''",
    "echo '=== routes 디렉토리 확인 ==='",
    "ls -la app/api/v1/routes/ 2>&1"
]

run_ssm(commands2, "2단계: Import 테스트", 30)

# 3. main.py 직접 실행 테스트
commands3 = [
    "cd ~/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "python3 -c 'import sys; sys.path.insert(0, \".\"); import main' 2>&1 | head -50"
]

run_ssm(commands3, "3단계: main.py 직접 실행", 30)

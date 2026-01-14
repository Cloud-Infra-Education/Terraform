#!/usr/bin/env python3
"""
서버 오류 진단 및 수정
"""
import subprocess
import json
import time

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"

def run_ssm(commands, wait=30):
    cmd = [
        "aws", "ssm", "send-command",
        "--instance-ids", INSTANCE_ID,
        "--region", REGION,
        "--document-name", "AWS-RunShellScript",
        "--parameters", json.dumps({"commands": commands}),
        "--output", "text", "--query", "Command.CommandId"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    cmd_id = result.stdout.strip()
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
    return data[0], data[1] if len(data) > 1 else "", data[2] if len(data) > 2 else ""

print("=" * 60)
print("서버 오류 진단")
print("=" * 60)

# 1. 로그 확인
commands = [
    "cd ~/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "echo '=== 서버 프로세스 ==='",
    "ps aux | grep '[u]vicorn' || echo '없음'",
    "echo ''",
    "echo '=== 서버 로그 (전체) ==='",
    "cat server.log 2>/dev/null | tail -100 || echo '로그 없음'"
]

status, output, error = run_ssm(commands, 30)
print("\n출력:")
print(output)
if error:
    print("\n오류:")
    print(error)

# 2. Python import 테스트
commands2 = [
    "cd ~/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "python3 -c 'import sys; sys.path.insert(0, \".\"); from app.core.config import settings; print(\"OK\")' 2>&1"
]

status2, output2, error2 = run_ssm(commands2, 20)
print("\n" + "=" * 60)
print("Python import 테스트:")
print(output2)
if error2:
    print(error2)

#!/usr/bin/env python3
"""
Backend 디렉토리 위치 확인 및 재전송
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
    if output:
        print("출력:")
        print(output)
    if error:
        print("오류:")
        print(error)
    print("=" * 60)
    return status == "Success", output, error

print("=" * 60)
print("Backend 디렉토리 위치 확인")
print("=" * 60)

# 1. Backend 디렉토리 찾기
commands1 = [
    "echo '=== /root 디렉토리 확인 ==='",
    "ls -la /root/ | head -20",
    "echo ''",
    "echo '=== Backend 검색 ==='",
    "find /root -name 'Backend' -type d 2>/dev/null | head -5",
    "echo ''",
    "echo '=== main.py 검색 ==='",
    "find /root -name 'main.py' -path '*/Backend/*' 2>/dev/null | head -5",
    "echo ''",
    "echo '=== 홈 디렉토리 확인 ==='",
    "ls -la ~/ 2>/dev/null | head -20"
]

run_ssm(commands1, "1단계: Backend 디렉토리 찾기", 30)

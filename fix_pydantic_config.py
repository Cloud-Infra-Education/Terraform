#!/usr/bin/env python3
"""
Pydantic Config 수정 및 서버 재시작
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
    if output:
        print(f"출력:\n{output[:2000] if len(output) > 2000 else output}")
    if error:
        print(f"오류:\n{error[:1000] if len(error) > 1000 else error}")
    return status == "Success", output, error

print("=" * 60)
print("Pydantic Config 수정 및 서버 재시작")
print("=" * 60)

# 1. Config 클래스에 extra = "ignore" 추가
commands1 = [
    "cd ~/Backend",
    """sed -i '/case_sensitive = True/a\\        extra = "ignore"  # .env 파일의 추가 필드 무시' app/core/config.py""",
    "grep -A 2 'case_sensitive' app/core/config.py",
    "python3 -c 'from app.core.config import settings; print(\"✅ Config 수정 확인\")' 2>&1"
]

run_ssm(commands1, "1단계: Config 수정", 30)

# 2. 서버 재시작
commands2 = [
    "cd ~/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "pkill -f uvicorn || true",
    "sleep 2",
    "nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &",
    "sleep 5",
    "ps aux | grep '[u]vicorn'",
    "tail -40 server.log"
]

run_ssm(commands2, "2단계: 서버 재시작", 30)

# 3. 서버 상태 확인
commands3 = [
    "cd ~/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "sleep 3",
    "curl -s http://localhost:8000/api/v1/health || echo '서버 응답 없음'",
    "ps aux | grep '[u]vicorn'",
    "ss -tlnp | grep 8000 || echo '포트 8000 미사용'"
]

run_ssm(commands3, "3단계: 서버 상태 확인", 15)

print("\n" + "=" * 60)
print("완료!")
print("=" * 60)
print("\nSSM 접속:")
print(f"aws ssm start-session --target {INSTANCE_ID} --region {REGION}")
print("\n접속 후:")
print("cd ~/Backend")
print("export PATH=$PATH:/root/.local/bin")
print("tail -f server.log")

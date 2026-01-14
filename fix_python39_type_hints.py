#!/usr/bin/env python3
"""
Python 3.9 타입 힌트 수정 및 서버 재시작
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
        print(output[:2000] if len(output) > 2000 else output)
    if error:
        print("오류:")
        print(error[:1000] if len(error) > 1000 else error)
    print("=" * 60)
    return status == "Success", output, error

print("=" * 60)
print("Python 3.9 타입 힌트 수정 및 서버 재시작")
print("=" * 60)

# 1. user_service.py 수정
commands1 = [
    "cd /root/Backend",
    "sed -i '1s/^/from typing import Optional\\n/' app/services/user_service.py",
    "sed -i 's/-> User | None:/-> Optional[User]:/g' app/services/user_service.py",
    "grep -A 1 'get_user_by_email' app/services/user_service.py",
    "grep -A 1 'get_user_by_id' app/services/user_service.py"
]

run_ssm(commands1, "1단계: user_service.py 수정", 20)

# 2. import 테스트
commands2 = [
    "cd /root/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "python3 -c 'import sys; sys.path.insert(0, \".\"); from app.services.user_service import user_service; print(\"✅ Import 성공\")' 2>&1"
]

run_ssm(commands2, "2단계: Import 테스트", 20)

# 3. 전체 import 테스트
commands3 = [
    "cd /root/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "python3 -c 'import sys; sys.path.insert(0, \".\"); import main; print(\"✅ main.py Import 성공\")' 2>&1 | head -50"
]

run_ssm(commands3, "3단계: main.py Import 테스트", 20)

# 4. 서버 실행
commands4 = [
    "cd /root/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "pkill -f uvicorn || true",
    "sleep 2",
    "nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &",
    "sleep 5",
    "ps aux | grep '[u]vicorn'",
    "tail -50 server.log"
]

run_ssm(commands4, "4단계: 서버 실행", 30)

# 5. 서버 상태 확인
commands5 = [
    "cd /root/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "sleep 3",
    "curl -s http://localhost:8000/api/v1/health || echo '서버 응답 없음'",
    "ps aux | grep '[u]vicorn'",
    "ss -tlnp | grep 8000 || netstat -tlnp | grep 8000 || echo '포트 8000 미사용'"
]

run_ssm(commands5, "5단계: 서버 상태 확인", 15)

print("\n" + "=" * 60)
print("완료!")
print("=" * 60)
print("\nSSM 접속:")
print(f"aws ssm start-session --target {INSTANCE_ID} --region {REGION}")
print("\n접속 후:")
print("sudo su -")
print("cd /root/Backend")
print("export PATH=$PATH:/root/.local/bin")
print("tail -f server.log")
print("curl http://localhost:8000/api/v1/health")

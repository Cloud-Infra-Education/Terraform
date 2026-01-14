#!/usr/bin/env python3
"""
실제 MySQL 연결 테스트
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
print("실제 MySQL 연결 테스트")
print("=" * 60)

# 1. Python으로 MySQL 연결 테스트
commands1 = [
    "cd /root/Backend",
    "export PATH=$PATH:/root/.local/bin",
    """python3 <<'PYEOF'
import sys
sys.path.insert(0, '.')
from app.core.config import settings
from app.core.database import engine
from sqlalchemy import text

print('=== MySQL 연결 테스트 ===')
print(f'DB Host: {settings.DB_HOST}')
print(f'DB Port: {settings.DB_PORT}')
print(f'DB User: {settings.DB_USER}')
print(f'DB Name: {settings.DB_NAME}')
print('')

try:
    with engine.connect() as conn:
        result = conn.execute(text('SELECT 1 as test'))
        row = result.fetchone()
        print(f'✅ 연결 성공! 테스트 쿼리 결과: {row[0]}')
        
        # 데이터베이스 목록 확인
        result = conn.execute(text('SHOW DATABASES'))
        databases = [row[0] for row in result]
        print(f'✅ 사용 가능한 데이터베이스: {databases}')
        
except Exception as e:
    print(f'❌ 연결 실패: {e}')
    import traceback
    traceback.print_exc()
PYEOF"""
]

run_ssm(commands1, "1단계: Python MySQL 연결 테스트", 30)

# 2. Backend 서버 재시작 (연결 풀 재초기화)
commands2 = [
    "cd /root/Backend",
    "export PATH=$PATH:/root/.local/bin",
    "pkill -f uvicorn || true",
    "sleep 2",
    "nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &",
    "sleep 5",
    "tail -30 server.log"
]

run_ssm(commands2, "2단계: 서버 재시작", 30)

# 3. API 테스트
commands3 = [
    "cd /root/Backend",
    "sleep 3",
    "curl -s http://localhost:8000/api/v1/health",
    "echo ''",
    "echo '=== 회원가입 API 테스트 ==='",
    "curl -s -X POST http://localhost:8000/api/v1/auth/register -H 'Content-Type: application/json' -d '{\"email\":\"test2@example.com\",\"password\":\"test1234\",\"region_code\":\"KR\",\"subscription_status\":\"free\"}' | head -20"
]

run_ssm(commands3, "3단계: API 테스트", 20)

print("\n" + "=" * 60)
print("테스트 완료!")
print("=" * 60)

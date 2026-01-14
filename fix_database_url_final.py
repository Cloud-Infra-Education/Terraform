#!/usr/bin/env python3
"""
Bastion에서 .env 파일의 DATABASE_URL 수정 (최종)
"""
import subprocess
import json
import time

REGION = "ap-northeast-2"
INSTANCE_ID = "i-0088889a043f54312"

print("=" * 60)
print("Bastion .env 파일 수정: DATABASE_URL")
print("=" * 60)

# Python 스크립트로 .env 파일 수정
python_script = """
import urllib.parse
import re

password = "StrongPassword123!"
encoded_password = urllib.parse.quote(password, safe='')
proxy_endpoint = "y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com"
database_url = f"mysql+pymysql://admin:{encoded_password}@{proxy_endpoint}:3306/y2om_db"

print(f"원본 비밀번호: {password}")
print(f"인코딩된 비밀번호: {encoded_password}")
print(f"새 DATABASE_URL: mysql+pymysql://admin:***@{proxy_endpoint}:3306/y2om_db")

# .env 파일 읽기
with open('/root/Backend/.env', 'r') as f:
    content = f.read()

# DATABASE_URL 라인 찾아서 교체
new_line = f"DATABASE_URL={database_url}\\n"
if re.search(r'^DATABASE_URL=', content, re.MULTILINE):
    content = re.sub(r'^DATABASE_URL=.*$', new_line.strip(), content, flags=re.MULTILINE)
    print("✅ DATABASE_URL 업데이트됨")
else:
    content += new_line
    print("✅ DATABASE_URL 추가됨")

# DB_PASSWORD도 업데이트
content = re.sub(r'^DB_PASSWORD=.*$', f"DB_PASSWORD={password}", content, flags=re.MULTILINE)

# .env 파일 쓰기
with open('/root/Backend/.env', 'w') as f:
    f.write(content)

print("✅ .env 파일 업데이트 완료!")

# 확인
print("\\n=== 업데이트된 DATABASE_URL ===")
with open('/root/Backend/.env', 'r') as f:
    for line in f:
        if line.startswith('DATABASE_URL='):
            # 비밀번호 부분 숨기기
            masked = re.sub(r'(password=)([^@]+)(@)', r'\\1***\\3', line.strip())
            print(masked)
            break

print("\\n=== 업데이트된 DB_PASSWORD ===")
with open('/root/Backend/.env', 'r') as f:
    for line in f:
        if line.startswith('DB_PASSWORD='):
            print(line.strip())
            break
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
    print("10초 대기 중...")
    time.sleep(10)
    
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
        print("✅ .env 파일 수정 완료!")
        print("=" * 60)
        print("\n다음 단계: 서버 재시작 및 연결 테스트")
        print("\nSSM 접속 후 다음 명령어 실행:")
        print("=" * 60)
        print("cd /root/Backend")
        print("export PATH=$PATH:/root/.local/bin")
        print("pkill -f uvicorn || true")
        print("sleep 2")
        print("nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &")
        print("sleep 5")
        print("python3 <<'PYEOF'")
        print("import sys")
        print("sys.path.insert(0, '.')")
        print("from app.core.database import engine")
        print("from sqlalchemy import text")
        print("try:")
        print("    with engine.connect() as conn:")
        print("        result = conn.execute(text('SELECT 1 as test'))")
        print("        row = result.fetchone()")
        print("        print(f'✅ 연결 성공! 테스트 쿼리 결과: {row[0]}')")
        print("except Exception as e:")
        print("    print(f'❌ 연결 실패: {e}')")
        print("PYEOF")
        print("tail -30 server.log")
        print("=" * 60)
    
except Exception as e:
    print(f"❌ 오류: {e}")

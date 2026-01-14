#!/usr/bin/env python3
"""
Backend 디렉토리 찾기 및 재전송
"""
import subprocess
import json
import time
import os
import tempfile
from datetime import datetime

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"
BACKEND_DIR = "/root/Backend"
BUCKET_NAME = "y2om-my-origin-bucket-123456"

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
        print(f"출력:\n{output}")
    if error:
        print(f"오류:\n{error}")
    return status == "Success", output, error

print("=" * 60)
print("Backend 디렉토리 찾기 및 재전송")
print("=" * 60)

# 1. Backend 디렉토리 찾기
commands1 = [
    "echo '=== /root 디렉토리 확인 ==='",
    "ls -la /root/ 2>/dev/null | head -20",
    "echo ''",
    "echo '=== Backend 검색 ==='",
    "find /root -name 'Backend' -type d 2>/dev/null",
    "echo ''",
    "echo '=== main.py 검색 ==='",
    "find /root -name 'main.py' 2>/dev/null | grep -i backend | head -3"
]

success1, output1, error1 = run_ssm(commands1, "1단계: Backend 디렉토리 찾기", 30)

# 2. Backend가 없으면 재전송
if "Backend" not in output1 and "main.py" not in output1:
    print("\nBackend 디렉토리를 찾을 수 없습니다. 재전송을 시작합니다...")
    
    # 압축
    print("\nBackend 디렉토리 압축 중...")
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.tar.gz')
    temp_file.close()
    
    exclude_options = [
        '--exclude=__pycache__',
        '--exclude=*.pyc',
        '--exclude=.git',
        '--exclude=test.db',
        '--exclude=.env'
    ]
    
    cmd = ['tar', '-czf', temp_file.name] + exclude_options + ['-C', os.path.dirname(BACKEND_DIR), os.path.basename(BACKEND_DIR)]
    subprocess.run(cmd, check=True, capture_output=True)
    file_size = os.path.getsize(temp_file.name)
    print(f"✅ 압축 완료: {temp_file.name} ({file_size / 1024 / 1024:.2f} MB)")
    
    # S3 업로드
    print("\nS3에 업로드 중...")
    key = f"backup/backend-{datetime.now().strftime('%Y%m%d-%H%M%S')}.tar.gz"
    cmd = [
        "aws", "s3", "cp", temp_file.name,
        f"s3://{BUCKET_NAME}/{key}",
        "--region", REGION
    ]
    subprocess.run(cmd, check=True, capture_output=True)
    print(f"✅ S3 업로드 완료: s3://{BUCKET_NAME}/{key}")
    
    # Bastion에서 다운로드 및 압축 해제
    commands2 = [
        "mkdir -p /root/Backend",
        f"cd /root/Backend",
        f"aws s3 cp s3://{BUCKET_NAME}/{key} backend.tar.gz",
        "tar -xzf backend.tar.gz --strip-components=1",
        "rm backend.tar.gz",
        "ls -la | head -20"
    ]
    
    success2, output2, error2 = run_ssm(commands2, "2단계: Backend 코드 다운로드 및 압축 해제", 60)
    
    # 임시 파일 정리
    try:
        os.unlink(temp_file.name)
    except:
        pass
    
    if success2:
        print("\n✅ Backend 코드 전송 완료!")
    else:
        print("\n❌ 코드 전송 실패")
else:
    print("\n✅ Backend 디렉토리를 찾았습니다!")

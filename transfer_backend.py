#!/usr/bin/env python3
"""
Backend 코드를 Bastion으로 전송
SSM과 SCP를 조합하여 사용
"""
import subprocess
import os
import json
import time
import tempfile

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"
BASTION_IP = "43.202.0.201"  # KOR Bastion Public IP
BASTION_USER = "ec2-user"
BACKEND_DIR = "/root/Backend"
SSH_KEY = "/root/KeyPair-Seoul.pem"

def run_command(cmd, check=True):
    """명령어 실행"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=check)
        return result.stdout.strip(), result.returncode
    except subprocess.CalledProcessError as e:
        return e.stderr, e.returncode

def main():
    print("=" * 60)
    print("Backend 코드를 Bastion으로 전송")
    print("=" * 60)
    print()
    
    # 1. SSH 키 확인
    if not os.path.exists(SSH_KEY):
        print(f"❌ SSH 키 파일을 찾을 수 없습니다: {SSH_KEY}")
        print()
        print("대안: Git에서 클론하거나 SSM Session Manager에서 수동으로 설정")
        return
    
    print(f"✅ SSH 키 확인: {SSH_KEY}")
    os.chmod(SSH_KEY, 0o400)
    
    # 2. Backend 디렉토리 확인
    if not os.path.exists(BACKEND_DIR):
        print(f"❌ Backend 디렉토리를 찾을 수 없습니다: {BACKEND_DIR}")
        return
    
    print(f"✅ Backend 디렉토리 확인: {BACKEND_DIR}")
    
    # 3. tar로 압축
    print()
    print("Backend 코드 압축 중...")
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
    stdout, code = run_command(' '.join(cmd), check=False)
    
    if code != 0:
        print(f"❌ 압축 실패: {stdout}")
        return
    
    file_size = os.path.getsize(temp_file.name)
    print(f"✅ 압축 완료: {temp_file.name} ({file_size / 1024 / 1024:.2f} MB)")
    
    # 4. SCP로 전송
    print()
    print(f"Bastion으로 파일 전송 중... ({BASTION_USER}@{BASTION_IP})")
    cmd = f"scp -i {SSH_KEY} {temp_file.name} {BASTION_USER}@{BASTION_IP}:/tmp/backend.tar.gz"
    stdout, code = run_command(cmd, check=False)
    
    if code != 0:
        print(f"❌ 전송 실패: {stdout}")
        print()
        print("대안: Git에서 클론하거나 SSM Session Manager에서 수동으로 설정")
        os.unlink(temp_file.name)
        return
    
    print("✅ 파일 전송 완료!")
    
    # 5. SSM을 통해 압축 해제
    print()
    print("Bastion에서 압축 해제 중...")
    
    commands = [
        "cd ~/Backend",
        "tar -xzf /tmp/backend.tar.gz --strip-components=1",
        "rm /tmp/backend.tar.gz",
        "ls -la | head -20"
    ]
    
    cmd = [
        "aws", "ssm", "send-command",
        "--instance-ids", INSTANCE_ID,
        "--region", REGION,
        "--document-name", "AWS-RunShellScript",
        "--parameters", json.dumps({"commands": commands}),
        "--output", "text",
        "--query", "Command.CommandId"
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        command_id = result.stdout.strip()
        print(f"Command ID: {command_id}")
        print("압축 해제 중... (20초 대기)")
        time.sleep(20)
        
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
        
        print()
        print(f"상태: {status}")
        if output:
            print(f"출력:\n{output}")
        if error:
            print(f"오류:\n{error}")
        
        if status == "Success":
            print()
            print("=" * 60)
            print("✅ Backend 코드 전송 및 설정 완료!")
            print("=" * 60)
            print()
            print("다음 단계:")
            print("1. SSM Session Manager로 Bastion 접속:")
            print(f"   aws ssm start-session --target {INSTANCE_ID} --region {REGION}")
            print()
            print("2. 접속 후 다음 명령어 실행:")
            print("   cd ~/Backend")
            print("   pip3 install --user -r requirements.txt")
            print("   python3 -m uvicorn main:app --host 0.0.0.0 --port 8000")
        else:
            print()
            print("❌ 압축 해제 실패")
    except Exception as e:
        print(f"❌ 오류: {e}")
    
    # 임시 파일 정리
    try:
        os.unlink(temp_file.name)
    except:
        pass

if __name__ == "__main__":
    main()

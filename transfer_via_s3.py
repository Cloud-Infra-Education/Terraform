#!/usr/bin/env python3
"""
S3를 통해 Backend 코드 전송 (GitHub 불필요, SSH 키 불필요)
"""
import subprocess
import os
import json
import time
from datetime import datetime

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"
BACKEND_DIR = "/root/Backend"
BUCKET_NAME = "y2om-my-origin-bucket-123456"  # terraform.tfvars에서 확인

def create_tarball():
    """Backend 디렉토리를 tar로 압축"""
    print("Backend 디렉토리 압축 중...")
    
    import tempfile
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
    
    try:
        subprocess.run(cmd, check=True, capture_output=True)
        file_size = os.path.getsize(temp_file.name)
        print(f"✅ 압축 완료: {temp_file.name} ({file_size / 1024 / 1024:.2f} MB)")
        return temp_file.name
    except subprocess.CalledProcessError as e:
        print(f"❌ 압축 실패: {e}")
        return None

def upload_to_s3(file_path):
    """S3에 업로드 (AWS CLI 사용)"""
    print(f"\nS3에 업로드 중: s3://{BUCKET_NAME}/")
    
    key = f"backup/backend-{datetime.now().strftime('%Y%m%d-%H%M%S')}.tar.gz"
    
    cmd = [
        "aws", "s3", "cp", file_path,
        f"s3://{BUCKET_NAME}/{key}",
        "--region", REGION
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=True)
        print(f"✅ S3 업로드 완료: s3://{BUCKET_NAME}/{key}")
        return key
    except subprocess.CalledProcessError as e:
        print(f"❌ S3 업로드 실패: {e.stderr}")
        return None
    except Exception as e:
        print(f"❌ S3 업로드 실패: {e}")
        return None

def download_and_extract(key):
    """Bastion에서 S3에서 다운로드 및 압축 해제"""
    print(f"\nBastion에서 다운로드 및 압축 해제 중...")
    
    commands = [
        "cd ~/Backend",
        f"aws s3 cp s3://{BUCKET_NAME}/{key} backend.tar.gz",
        "tar -xzf backend.tar.gz --strip-components=1",
        "rm backend.tar.gz",
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
        print("명령어 실행 중... (60초 대기)")
        time.sleep(60)
        
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
            print(f"출력:\n{output}")
        if error:
            print(f"오류:\n{error}")
        
        return status == "Success", key
    except Exception as e:
        print(f"❌ 오류: {e}")
        return False, key

def main():
    print("=" * 60)
    print("S3를 통해 Backend 코드 전송 (GitHub 불필요)")
    print("=" * 60)
    print()
    
    # 1. 압축
    tarball_path = create_tarball()
    if not tarball_path:
        return
    
    # 2. S3 업로드
    s3_key = upload_to_s3(tarball_path)
    if not s3_key:
        os.unlink(tarball_path)
        return
    
    # 3. Bastion에서 다운로드 및 압축 해제
    success, key = download_and_extract(s3_key)
    
    # 임시 파일 정리
    try:
        os.unlink(tarball_path)
    except:
        pass
    
    if success:
        print("\n" + "=" * 60)
        print("✅ Backend 코드 전송 완료!")
        print("=" * 60)
        print("\n다음 단계:")
        print("1. SSM Session Manager로 Bastion 접속:")
        print(f"   aws ssm start-session --target {INSTANCE_ID} --region {REGION}")
        print("\n2. 접속 후 다음 명령어 실행:")
        print("   cd ~/Backend")
        print("   ls -la")
        print("   pip3 install --user -r requirements.txt")
        print("   python3 -m uvicorn main:app --host 0.0.0.0 --port 8000")
    else:
        print("\n❌ 코드 전송 실패")
        print(f"\n수동으로 다운로드:")
        print(f"  aws ssm start-session --target {INSTANCE_ID} --region {REGION}")
        print(f"  cd ~/Backend")
        print(f"  aws s3 cp s3://{BUCKET_NAME}/{key} backend.tar.gz")
        print(f"  tar -xzf backend.tar.gz --strip-components=1")

if __name__ == "__main__":
    main()

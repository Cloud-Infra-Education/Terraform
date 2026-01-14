#!/usr/bin/env python3
"""
SSM을 통해 Backend 코드를 Bastion으로 전송
tar + base64 인코딩을 사용하여 파일 전송
"""
import subprocess
import os
import base64
import json
import tempfile

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"
BACKEND_DIR = "/root/Backend"

def create_tarball():
    """Backend 디렉토리를 tar로 압축"""
    print("Backend 디렉토리 압축 중...")
    
    # 임시 파일 생성
    temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.tar.gz')
    temp_file.close()
    
    # tar로 압축 (불필요한 파일 제외)
    exclude_patterns = [
        '--exclude=__pycache__',
        '--exclude=*.pyc',
        '--exclude=.git',
        '--exclude=test.db',
        '--exclude=.env'  # .env는 이미 생성됨
    ]
    
    cmd = ['tar', '-czf', temp_file.name] + exclude_patterns + ['-C', os.path.dirname(BACKEND_DIR), os.path.basename(BACKEND_DIR)]
    
    try:
        subprocess.run(cmd, check=True, capture_output=True)
        print(f"✅ 압축 완료: {temp_file.name}")
        return temp_file.name
    except subprocess.CalledProcessError as e:
        print(f"❌ 압축 실패: {e}")
        return None

def upload_via_s3(tarball_path):
    """S3를 통해 파일 업로드 후 Bastion에서 다운로드"""
    import boto3
    from datetime import datetime
    
    s3_client = boto3.client('s3', region_name=REGION)
    bucket_name = "y2om-my-origin-bucket-123456"  # terraform.tfvars에서 확인
    key = f"backup/backend-{datetime.now().strftime('%Y%m%d-%H%M%S')}.tar.gz"
    
    try:
        print(f"S3에 업로드 중: s3://{bucket_name}/{key}")
        s3_client.upload_file(tarball_path, bucket_name, key)
        print("✅ S3 업로드 완료")
        
        # Bastion에서 다운로드 및 압축 해제
        commands = [
            f"cd ~/Backend",
            f"aws s3 cp s3://{bucket_name}/{key} backend.tar.gz",
            "tar -xzf backend.tar.gz",
            "rm backend.tar.gz",
            "ls -la"
        ]
        
        return commands, key
    except Exception as e:
        print(f"❌ S3 업로드 실패: {e}")
        return None, None

def send_via_ssm_base64(tarball_path):
    """SSM을 통해 base64 인코딩된 파일 전송"""
    print("파일을 base64로 인코딩 중...")
    
    # 파일 읽기 및 인코딩
    with open(tarball_path, 'rb') as f:
        file_data = f.read()
        encoded = base64.b64encode(file_data).decode('utf-8')
    
    print(f"인코딩 완료 (크기: {len(encoded)} bytes)")
    
    # 파일 크기가 너무 크면 S3 사용
    if len(encoded) > 200000:  # 약 200KB
        print("⚠️  파일이 너무 큽니다. S3를 사용합니다.")
        return None, None
    
    # SSM을 통해 전송
    commands = [
        "cd ~/Backend",
        f"cat > backend.tar.gz.b64 <<'ENDOFFILE'\n{encoded}\nENDOFFILE",
        "base64 -d backend.tar.gz.b64 > backend.tar.gz",
        "tar -xzf backend.tar.gz",
        "rm backend.tar.gz backend.tar.gz.b64",
        "ls -la"
    ]
    
    return commands, None

def run_ssm_command(commands, description):
    """SSM을 통해 명령어 실행"""
    print(f"\n{description}...")
    
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
        
        # 결과 대기
        print("명령어 실행 중... (60초 대기)")
        import time
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
        
        print(f"상태: {status}")
        if output:
            print(f"출력:\n{output}")
        if error:
            print(f"오류:\n{error}")
        
        return status == "Success"
    except Exception as e:
        print(f"오류: {e}")
        return False

def main():
    print("=" * 60)
    print("Backend 코드를 Bastion으로 전송")
    print("=" * 60)
    
    # 1. tar 압축
    tarball_path = create_tarball()
    if not tarball_path:
        print("❌ 압축 실패")
        return
    
    # 파일 크기 확인
    file_size = os.path.getsize(tarball_path)
    print(f"압축 파일 크기: {file_size / 1024 / 1024:.2f} MB")
    
    # 2. 전송 방법 선택
    if file_size > 200 * 1024:  # 200KB 이상이면 S3 사용
        print("\n파일이 큽니다. S3를 통해 전송합니다...")
        commands, s3_key = upload_via_s3(tarball_path)
        if not commands:
            print("❌ S3 업로드 실패")
            return
    else:
        print("\nSSM을 통해 직접 전송합니다...")
        commands, s3_key = send_via_ssm_base64(tarball_path)
        if not commands:
            print("❌ 인코딩 실패")
            return
    
    # 3. SSM을 통해 실행
    if run_ssm_command(commands, "Backend 코드 전송 및 압축 해제"):
        print("\n✅ Backend 코드 전송 완료!")
        print("\n다음 단계:")
        print("  cd ~/Backend")
        print("  pip3 install --user -r requirements.txt")
        print("  python3 -m uvicorn main:app --host 0.0.0.0 --port 8000")
    else:
        print("\n❌ 코드 전송 실패")
    
    # 임시 파일 정리
    try:
        os.unlink(tarball_path)
        if s3_key:
            print(f"\nS3 파일 정리: s3://y2om-my-origin-bucket-123456/{s3_key}")
    except:
        pass

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Bastion 호스트에서 Backend 자동 설정
SSM Session Manager를 통해 실행
"""
import subprocess
import time
import json

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"

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
        print("명령어 실행 중... (30초 대기)")
        time.sleep(30)
        
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
    except subprocess.CalledProcessError as e:
        print(f"오류: {e}")
        print(f"stderr: {e.stderr}")
        return False
    except Exception as e:
        print(f"예외 발생: {e}")
        return False

def main():
    print("=" * 60)
    print("Bastion 호스트에서 Backend 자동 설정")
    print("=" * 60)
    
    # 1단계: 필요한 도구 설치
    commands1 = [
        "sudo yum update -y",
        "sudo yum install -y python3 python3-pip git mysql",
        "python3 --version",
        "pip3 --version"
    ]
    
    if not run_ssm_command(commands1, "1단계: 필요한 도구 설치"):
        print("❌ 도구 설치 실패")
        return
    
    # 2단계: Backend 디렉토리 생성 및 환경 변수 설정
    env_content = """# Database (RDS Proxy 엔드포인트)
DB_HOST=y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com
DB_PORT=3306
DB_USER=admin
DB_PASSWORD=StrongPassword123!
DB_NAME=formation_lap

# Database URL
DATABASE_URL=mysql+pymysql://admin:StrongPassword123!@y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com:3306/formation_lap

# Keycloak
KEYCLOAK_URL=http://keycloak-service:8080
KEYCLOAK_REALM=formation-lap
KEYCLOAK_CLIENT_ID=backend-client

# Meilisearch
MEILISEARCH_URL=http://meilisearch-service:7700
MEILISEARCH_API_KEY=masterKey123

# 기타
DEBUG=false
ENVIRONMENT=production"""
    
    commands2 = [
        "cd ~",
        "mkdir -p Backend",
        "cd Backend",
        f"cat > .env <<'ENVEOF'\n{env_content}\nENVEOF",
        "chmod 600 .env",
        "pwd",
        "ls -la .env"
    ]
    
    if not run_ssm_command(commands2, "2단계: Backend 디렉토리 생성 및 환경 변수 설정"):
        print("❌ 환경 변수 설정 실패")
        return
    
    print("\n" + "=" * 60)
    print("다음 단계")
    print("=" * 60)
    print("\n✅ 기본 설정 완료!")
    print("\n이제 Backend 코드를 전송해야 합니다:")
    print("\n옵션 1: SCP로 전송")
    print("  cd /root/Terraform")
    print("  ./copy_backend_to_bastion.sh")
    print("\n옵션 2: Git에서 클론 (SSM Session Manager에서)")
    print(f"  aws ssm start-session --target {INSTANCE_ID} --region {REGION}")
    print("  cd ~/Backend")
    print("  git clone <your-backend-repo-url> .")
    print("\n옵션 3: 수동 설정")
    print("  SSM Session Manager로 접속하여 직접 설정")
    print("\n코드 전송 후:")
    print("  cd ~/Backend")
    print("  pip3 install --user -r requirements.txt")
    print("  python3 -m uvicorn main:app --host 0.0.0.0 --port 8000")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""
Bastion에서 Backend 설정 수정 및 서버 실행
"""
import subprocess
import json
import time

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"

def run_ssm_command(commands, description, wait_time=60):
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
        print(f"명령어 실행 중... ({wait_time}초 대기)")
        time.sleep(wait_time)
        
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
            if len(output) > 2000:
                print(f"출력: (처음 1000자)\n{output[:1000]}...")
            else:
                print(f"출력:\n{output}")
        if error:
            print(f"오류:\n{error}")
        
        return status == "Success", output, error
    except Exception as e:
        print(f"오류: {e}")
        return False, "", str(e)

def main():
    print("=" * 60)
    print("Backend 설정 수정 및 서버 실행")
    print("=" * 60)
    
    # config.py 수정 (ENVIRONMENT 필드 추가)
    config_fix = """# Application
    APP_NAME: str = "Backend API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ENVIRONMENT: Optional[str] = None"""
    
    # config.py 파일 수정
    commands1 = [
        "cd ~/Backend",
        """cat > /tmp/config_fix.txt <<'ENDOFFILE'
    # Application
    APP_NAME: str = "Backend API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ENVIRONMENT: Optional[str] = None
ENDOFFILE""",
        "sed -i '/DEBUG: bool = False/a\\    ENVIRONMENT: Optional[str] = None' app/core/config.py",
        "grep -A 1 'DEBUG: bool' app/core/config.py"
    ]
    
    success1, output1, error1 = run_ssm_command(commands1, "1단계: config.py 수정", wait_time=30)
    
    # PATH 추가 및 서버 실행
    commands2 = [
        "cd ~/Backend",
        "export PATH=$PATH:/root/.local/bin",
        "pkill -f uvicorn || true",
        "sleep 2",
        "nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &",
        "sleep 5",
        "ps aux | grep uvicorn | grep -v grep",
        "tail -30 server.log"
    ]
    
    success2, output2, error2 = run_ssm_command(commands2, "2단계: Backend 서버 실행", wait_time=30)
    
    # 서버 상태 확인
    commands3 = [
        "cd ~/Backend",
        "export PATH=$PATH:/root/.local/bin",
        "curl -s http://localhost:8000/api/v1/health || echo '서버 시작 중...'",
        "ps aux | grep uvicorn | grep -v grep",
        "netstat -tlnp | grep 8000 || ss -tlnp | grep 8000 || echo '포트 확인 중...'"
    ]
    
    success3, output3, error3 = run_ssm_command(commands3, "3단계: 서버 상태 확인", wait_time=10)
    
    print("\n" + "=" * 60)
    if success2 or success3:
        print("✅ Backend 서버 실행 완료!")
    else:
        print("⚠️  서버 실행에 문제가 있을 수 있습니다.")
    print("=" * 60)
    print("\n다음 단계:")
    print("1. SSM Session Manager로 Bastion 접속:")
    print(f"   aws ssm start-session --target {INSTANCE_ID} --region {REGION}")
    print("\n2. 접속 후 서버 상태 확인:")
    print("   cd ~/Backend")
    print("   export PATH=$PATH:/root/.local/bin")
    print("   tail -f server.log")
    print("   curl http://localhost:8000/api/v1/health")

if __name__ == "__main__":
    main()

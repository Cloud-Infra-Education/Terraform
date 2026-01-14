#!/usr/bin/env python3
"""
Bastion 서버 로그 확인 및 오류 진단
"""
import subprocess
import json
import time

INSTANCE_ID = "i-0088889a043f54312"
REGION = "ap-northeast-2"

def run_ssm_command(commands, description, wait_time=30):
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
        print("=" * 60)
        if output:
            print("출력:")
            print(output)
        if error:
            print("오류:")
            print(error)
        print("=" * 60)
        
        return status == "Success", output, error
    except Exception as e:
        print(f"오류: {e}")
        return False, "", str(e)

def main():
    print("=" * 60)
    print("Bastion 서버 로그 확인 및 진단")
    print("=" * 60)
    
    # 서버 로그 확인
    commands1 = [
        "cd ~/Backend",
        "export PATH=$PATH:/root/.local/bin",
        "echo '=== 서버 프로세스 확인 ==='",
        "ps aux | grep '[u]vicorn' || echo '서버가 실행되지 않음'",
        "echo ''",
        "echo '=== 서버 로그 (마지막 50줄) ==='",
        "tail -50 server.log 2>/dev/null || echo '로그 파일 없음'",
        "echo ''",
        "echo '=== config.py 확인 ==='",
        "grep -A 3 'DEBUG: bool' app/core/config.py",
        "echo ''",
        "echo '=== Python 모듈 import 테스트 ==='",
        "python3 -c 'from app.core.config import settings; print(\"✅ config import 성공\")' 2>&1"
    ]
    
    success1, output1, error1 = run_ssm_command(commands1, "서버 상태 및 로그 확인", wait_time=30)
    
    # 서버 재시작 시도
    if "서버가 실행되지 않음" in output1 or "서버가 실행되지 않음" in error1:
        print("\n서버가 실행되지 않았습니다. 재시작을 시도합니다...")
        commands2 = [
            "cd ~/Backend",
            "export PATH=$PATH:/root/.local/bin",
            "pkill -f uvicorn || true",
            "sleep 2",
            "echo '서버 시작 중...'",
            "python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &",
            "sleep 5",
            "ps aux | grep '[u]vicorn'",
            "tail -30 server.log"
        ]
        
        success2, output2, error2 = run_ssm_command(commands2, "서버 재시작", wait_time=30)
        
        # 서버 상태 재확인
        commands3 = [
            "cd ~/Backend",
            "export PATH=$PATH:/root/.local/bin",
            "sleep 3",
            "curl -s http://localhost:8000/api/v1/health || echo '서버 응답 없음'",
            "ps aux | grep '[u]vicorn'",
            "ss -tlnp | grep 8000 || netstat -tlnp | grep 8000 || echo '포트 8000이 열려있지 않음'"
        ]
        
        success3, output3, error3 = run_ssm_command(commands3, "서버 상태 재확인", wait_time=15)

if __name__ == "__main__":
    main()

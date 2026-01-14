#!/usr/bin/env python3
"""
Bastion에서 Backend 의존성 설치 및 서버 실행
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
            # 출력이 너무 길면 일부만 표시
            if len(output) > 2000:
                print(f"출력: (처음 1000자)\n{output[:1000]}...")
                print(f"\n... (총 {len(output)}자, 나머지 생략)")
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
    print("Bastion에서 Backend 설정 및 실행")
    print("=" * 60)
    
    # 1단계: Python 의존성 설치
    commands1 = [
        "cd ~/Backend",
        "pip3 install --user -r requirements.txt",
        "pip3 list --user | grep -E '(fastapi|uvicorn|sqlalchemy|pymysql|meilisearch)'"
    ]
    
    success1, output1, error1 = run_ssm_command(commands1, "1단계: Python 의존성 설치", wait_time=120)
    
    if not success1:
        print("\n⚠️  의존성 설치에 문제가 있을 수 있습니다.")
        if error1:
            print(f"오류 내용: {error1}")
    
    # 2단계: 데이터베이스 연결 테스트
    commands2 = [
        "cd ~/Backend",
        "mysql -h y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com -u admin -p'StrongPassword123!' -e 'SELECT 1;' 2>&1 || echo 'DB 연결 테스트 완료'"
    ]
    
    success2, output2, error2 = run_ssm_command(commands2, "2단계: 데이터베이스 연결 테스트", wait_time=30)
    
    # 3단계: Backend 서버 실행 (백그라운드)
    commands3 = [
        "cd ~/Backend",
        "pkill -f uvicorn || true",  # 기존 프로세스 종료
        "nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &",
        "sleep 3",
        "ps aux | grep uvicorn | grep -v grep",
        "tail -20 server.log"
    ]
    
    success3, output3, error3 = run_ssm_command(commands3, "3단계: Backend 서버 실행", wait_time=30)
    
    # 4단계: 서버 상태 확인
    commands4 = [
        "cd ~/Backend",
        "curl -s http://localhost:8000/api/v1/health || echo '서버 시작 중...'",
        "ps aux | grep uvicorn | grep -v grep",
        "netstat -tlnp | grep 8000 || ss -tlnp | grep 8000"
    ]
    
    success4, output4, error4 = run_ssm_command(commands4, "4단계: 서버 상태 확인", wait_time=10)
    
    print("\n" + "=" * 60)
    print("설정 완료!")
    print("=" * 60)
    print("\n다음 단계:")
    print("1. SSM Session Manager로 Bastion 접속:")
    print(f"   aws ssm start-session --target {INSTANCE_ID} --region {REGION}")
    print("\n2. 접속 후 서버 상태 확인:")
    print("   cd ~/Backend")
    print("   tail -f server.log")
    print("   curl http://localhost:8000/api/v1/health")
    print("\n3. 서버 중지 (필요시):")
    print("   pkill -f uvicorn")

if __name__ == "__main__":
    main()

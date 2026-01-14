#!/usr/bin/env python3
"""
RDS Proxy 연결 문제 진단
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
print("RDS Proxy 연결 문제 진단")
print("=" * 60)

# 1. .env 파일 확인
commands1 = [
    "cd /root/Backend",
    "echo '=== .env 파일 확인 ==='",
    "grep -E 'DB_|DATABASE' .env | sed 's/password=.*/password=***/'",
    "echo ''",
    "echo '=== RDS Proxy 엔드포인트 확인 ==='",
    "grep 'DB_HOST' .env"
]

run_ssm(commands1, "1단계: .env 파일 확인", 20)

# 2. 네트워크 연결 테스트
commands2 = [
    "cd /root/Backend",
    "DB_HOST=$(grep '^DB_HOST=' .env | cut -d'=' -f2)",
    "DB_PORT=$(grep '^DB_PORT=' .env | cut -d'=' -f2 || echo '3306')",
    "echo 'RDS Proxy 엔드포인트: $DB_HOST'",
    "echo '포트: $DB_PORT'",
    "echo ''",
    "echo '=== 네트워크 연결 테스트 ==='",
    "timeout 5 bash -c 'echo > /dev/tcp/$DB_HOST/$DB_PORT' 2>&1 && echo '✅ 연결 성공' || echo '❌ 연결 실패'",
    "echo ''",
    "echo '=== DNS 확인 ==='",
    "nslookup $DB_HOST 2>&1 | head -10 || host $DB_HOST 2>&1 | head -5"
]

run_ssm(commands2, "2단계: 네트워크 연결 테스트", 30)

# 3. 보안 그룹 확인
commands3 = [
    "echo '=== Bastion 인스턴스 정보 ==='",
    "INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)",
    "echo 'Instance ID: $INSTANCE_ID'",
    "echo ''",
    "echo '=== 보안 그룹 확인 ==='",
    "aws ec2 describe-instances --instance-ids $INSTANCE_ID --region ap-northeast-2 --query 'Reservations[0].Instances[0].SecurityGroups[*].GroupId' --output text"
]

run_ssm(commands3, "3단계: 보안 그룹 확인", 20)

# 4. RDS Proxy 보안 그룹 확인
commands4 = [
    "echo '=== RDS Proxy 보안 그룹 확인 ==='",
    "DB_HOST=$(grep '^DB_HOST=' /root/Backend/.env | cut -d'=' -f2)",
    "PROXY_NAME=$(echo $DB_HOST | cut -d'.' -f1)",
    "echo 'Proxy 이름: $PROXY_NAME'",
    "aws rds describe-db-proxies --db-proxy-name $PROXY_NAME --region ap-northeast-2 --query 'DBProxies[0].VpcSecurityGroupIds' --output text 2>&1"
]

run_ssm(commands4, "4단계: RDS Proxy 보안 그룹 확인", 20)

print("\n" + "=" * 60)
print("진단 완료!")
print("=" * 60)

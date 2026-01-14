#!/usr/bin/env python3
"""
최종 진단: .env 파일과 RDS 상태 확인
"""
import subprocess
import json
import urllib.parse

REGION = "ap-northeast-2"
CLUSTER_ID = "y2om-kor-aurora-mysql"
INSTANCE_ID = "i-0088889a043f54312"

print("=" * 60)
print("최종 진단: RDS 연결 문제")
print("=" * 60)

# 1. RDS 클러스터 상태 확인
print("\n1단계: RDS 클러스터 상태 확인...")
cmd = [
    "aws", "rds", "describe-db-clusters",
    "--db-cluster-identifier", CLUSTER_ID,
    "--region", REGION,
    "--query", "DBClusters[0].[Status,PendingModifiedValues]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    status = data[0]
    pending = data[1] if data[1] else {}
    
    print(f"✅ 클러스터 상태: {status}")
    if pending:
        print(f"⚠️  대기 중인 변경사항:")
        for key, value in pending.items():
            print(f"   - {key}: {value}")
        print(f"\n   ⚠️  비밀번호 변경이 완료될 때까지 기다려야 합니다!")
    else:
        print(f"✅ 변경사항 없음 (비밀번호 변경 완료)")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 2. Secrets Manager 확인
print("\n2단계: Secrets Manager 확인...")
cmd = [
    "aws", "secretsmanager", "get-secret-value",
    "--secret-id", "formation-lap/db/dev/credentials",
    "--region", REGION,
    "--query", "SecretString",
    "--output", "text"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    secret_data = json.loads(result.stdout)
    password = secret_data.get('password', '')
    print(f"✅ Secrets Manager 비밀번호: {password[:5]}...{password[-3:] if len(password) > 8 else ''}")
    print(f"   전체 비밀번호: {password}")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 3. Bastion에서 .env 파일 확인
print("\n3단계: Bastion에서 .env 파일 확인...")
commands = [
    "cd /root/Backend",
    "echo '=== DATABASE_URL 확인 ==='",
    "grep '^DATABASE_URL=' .env | head -1",
    "echo ''",
    "echo '=== DB_PASSWORD 확인 ==='",
    "grep '^DB_PASSWORD=' .env | head -1",
    "echo ''",
    "echo '=== DATABASE_URL 비밀번호 부분 추출 ==='",
    "grep '^DATABASE_URL=' .env | sed -n 's/.*password=\\([^@]*\\)@.*/password 부분: \\1/p'"
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

print("명령어 실행 중...")
try:
    result = subprocess.run(cmd_ssm, capture_output=True, text=True, check=True)
    command_id = result.stdout.strip()
    print(f"Command ID: {command_id}")
    print("10초 대기 중...")
    import time
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
except Exception as e:
    print(f"❌ SSM 명령어 실행 실패: {e}")

# 4. 예상 DATABASE_URL 생성
print("\n4단계: 예상 DATABASE_URL 형식...")
expected_password = "StrongPassword123!"
encoded_password = urllib.parse.quote(expected_password, safe='')
print(f"원본 비밀번호: {expected_password}")
print(f"URL 인코딩된 비밀번호: {encoded_password}")
print(f"예상 DATABASE_URL 형식:")
print(f"  mysql+pymysql://admin:{encoded_password}@y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com:3306/y2om_db")

print("\n" + "=" * 60)
print("해결 방법:")
print("=" * 60)
print("1. RDS 클러스터 비밀번호 변경이 완료될 때까지 대기 (보통 1-2분)")
print("2. Bastion에서 .env 파일의 DATABASE_URL 확인")
print("3. DATABASE_URL의 비밀번호 부분이 URL 인코딩되어 있는지 확인")
print("4. 필요시 .env 파일 수정 후 서버 재시작")

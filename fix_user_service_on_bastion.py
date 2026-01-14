#!/usr/bin/env python3
"""
Bastion에서 user_service.py 수정 (Keycloak 실패 시에도 계속 진행)
"""
import subprocess
import json

REGION = "ap-northeast-2"
INSTANCE_ID = "i-0088889a043f54312"

print("=" * 60)
print("Bastion에서 user_service.py 수정")
print("=" * 60)

# user_service.py 수정 스크립트
python_script = """
# user_service.py 파일 읽기
with open('/root/Backend/app/services/user_service.py', 'r') as f:
    content = f.read()

# 기존 코드 찾기 (정확한 매칭)
old_code = '''        # Keycloak에 사용자 생성
        keycloak_user_id = None
        try:
            keycloak_user_id = await UserService._create_keycloak_user(user_data)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to create user in Keycloak: {str(e)}"
            )'''

# 새 코드로 교체
new_code = '''        # Keycloak에 사용자 생성 (선택적 - 실패해도 계속 진행)
        keycloak_user_id = None
        try:
            keycloak_user_id = await UserService._create_keycloak_user(user_data)
        except Exception as e:
            # Keycloak이 없거나 접근 불가능한 경우 경고만 출력하고 계속 진행
            print(f"⚠️  Keycloak 사용자 생성 실패 (무시하고 계속 진행): {str(e)}")'''

# 코드 교체
if old_code in content:
    content = content.replace(old_code, new_code)
    print('✅ user_service.py 수정 완료!')
    
    # 파일 쓰기
    with open('/root/Backend/app/services/user_service.py', 'w') as f:
        f.write(content)
    
    # 확인
    print('\\n=== 수정된 부분 확인 ===')
    with open('/root/Backend/app/services/user_service.py', 'r') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if 'Keycloak에 사용자 생성' in line:
                for j in range(10):
                    if i+j < len(lines):
                        print(lines[i+j].rstrip())
                break
else:
    print('⚠️  기존 코드를 찾을 수 없습니다.')
    print('\\n현재 create_user 메서드 확인:')
    with open('/root/Backend/app/services/user_service.py', 'r') as f:
        lines = f.readlines()
        for i, line in enumerate(lines):
            if 'async def create_user' in line:
                for j in range(30):
                    if i+j < len(lines):
                        print(lines[i+j].rstrip())
                break
"""

commands = [
    "cd /root/Backend",
    "python3 <<'PYEOF'",
    python_script,
    "PYEOF"
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

print("\n명령어 실행 중...")
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
    print(f"❌ 오류: {e}")

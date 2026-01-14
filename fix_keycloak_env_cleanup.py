#!/usr/bin/env python3
"""
.env 파일의 Keycloak 설정 정리 및 올바른 URL 확인
"""
import subprocess
import json
import re

REGION = "ap-northeast-2"
INSTANCE_ID = "i-0088889a043f54312"

print("=" * 60)
print("Keycloak 설정 정리 및 확인")
print("=" * 60)

# .env 파일 정리 스크립트
python_script = """
import re

# .env 파일 읽기
with open('/root/Backend/.env', 'r') as f:
    lines = f.readlines()

# Keycloak 관련 라인만 추출 (첫 번째 것만 유지)
keycloak_settings = {}
keycloak_keys = [
    'KEYCLOAK_URL',
    'KEYCLOAK_REALM',
    'KEYCLOAK_CLIENT_ID',
    'KEYCLOAK_CLIENT_SECRET',
    'KEYCLOAK_ADMIN_USERNAME',
    'KEYCLOAK_ADMIN_PASSWORD'
]

# 모든 라인을 순회하면서 Keycloak 설정 수집 (첫 번째 것만)
new_lines = []
seen_keys = set()

for line in lines:
    line_stripped = line.strip()
    if line_stripped and not line_stripped.startswith('#'):
        for key in keycloak_keys:
            if line_stripped.startswith(f'{key}='):
                if key not in seen_keys:
                    seen_keys.add(key)
                    keycloak_settings[key] = line_stripped
                # 중복이므로 이 라인은 추가하지 않음
                break
        else:
            # Keycloak 설정이 아니면 그대로 추가
            new_lines.append(line)

# Keycloak 설정을 올바른 순서로 추가
if keycloak_settings:
    # 기존 Keycloak 설정 라인 제거 후 다시 추가
    new_lines.append('\\n# Keycloak 설정\\n')
    for key in keycloak_keys:
        if key in keycloak_settings:
            new_lines.append(keycloak_settings[key] + '\\n')
        elif key in ['KEYCLOAK_URL', 'KEYCLOAK_REALM', 'KEYCLOAK_ADMIN_USERNAME', 'KEYCLOAK_ADMIN_PASSWORD']:
            # 필수 설정이 없으면 기본값 추가
            if key == 'KEYCLOAK_URL':
                new_lines.append('KEYCLOAK_URL=http://keycloak-service:8080\\n')
            elif key == 'KEYCLOAK_REALM':
                new_lines.append('KEYCLOAK_REALM=formation-lap\\n')
            elif key == 'KEYCLOAK_ADMIN_USERNAME':
                new_lines.append('KEYCLOAK_ADMIN_USERNAME=admin\\n')
            elif key == 'KEYCLOAK_ADMIN_PASSWORD':
                new_lines.append('KEYCLOAK_ADMIN_PASSWORD=admin\\n')

# .env 파일 쓰기
with open('/root/Backend/.env', 'w') as f:
    f.writelines(new_lines)

print('✅ .env 파일 정리 완료!')
print('\\n=== 정리된 Keycloak 설정 ===')
with open('/root/Backend/.env', 'r') as f:
    for line in f:
        if line.strip().startswith('KEYCLOAK'):
            print(line.strip())
"""

commands = [
    "cd /root/Backend",
    "python3 <<'PYEOF'",
    python_script,
    "PYEOF",
    "",
    "# Keycloak URL 테스트",
    "echo '=== Keycloak URL 접근 테스트 ==='",
    "echo '1. keycloak-service:8080:'",
    "curl -s --connect-timeout 3 http://keycloak-service:8080/health || echo '  접근 불가'",
    "echo ''",
    "echo '2. keycloak.matchacake.click:'",
    "curl -s --connect-timeout 3 http://keycloak.matchacake.click/health || echo '  접근 불가'",
    "echo ''",
    "echo '3. HTTPS keycloak.matchacake.click:'",
    "curl -s --connect-timeout 3 https://keycloak.matchacake.click/health || echo '  접근 불가'"
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

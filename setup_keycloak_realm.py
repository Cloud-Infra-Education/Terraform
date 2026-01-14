#!/usr/bin/env python3
"""
Keycloak Realm 및 Client 설정
"""
import subprocess
import json
import time

REGION = "ap-northeast-2"
INSTANCE_ID = "i-0088889a043f54312"

print("=" * 60)
print("Keycloak Realm 및 Client 설정")
print("=" * 60)

# Keycloak Admin API를 사용하여 Realm 생성
python_script = """
import httpx
import asyncio
import json

KEYCLOAK_URL = "https://api.matchacake.click/keycloak"
ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "admin"
REALM_NAME = "formation-lap"
CLIENT_ID = "backend-client"

async def setup_keycloak():
    print(f"Keycloak URL: {KEYCLOAK_URL}")
    
    # 1. Admin 토큰 가져오기
    print("\\n1단계: Admin 토큰 가져오기...")
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            # Admin 토큰 요청
            token_response = await client.post(
                f"{KEYCLOAK_URL}/realms/master/protocol/openid-connect/token",
                data={
                    "grant_type": "password",
                    "client_id": "admin-cli",
                    "username": ADMIN_USERNAME,
                    "password": ADMIN_PASSWORD,
                },
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
            
            if token_response.status_code != 200:
                print(f"❌ Admin 토큰 가져오기 실패: {token_response.status_code}")
                print(f"   응답: {token_response.text}")
                return False
            
            token_data = token_response.json()
            admin_token = token_data.get("access_token")
            print(f"✅ Admin 토큰 획득 성공")
            
            # 2. Realm 존재 확인
            print(f"\\n2단계: Realm '{REALM_NAME}' 확인...")
            realm_response = await client.get(
                f"{KEYCLOAK_URL}/admin/realms/{REALM_NAME}",
                headers={
                    "Authorization": f"Bearer {admin_token}",
                    "Content-Type": "application/json"
                },
            )
            
            if realm_response.status_code == 200:
                print(f"✅ Realm '{REALM_NAME}' 이미 존재")
            elif realm_response.status_code == 404:
                print(f"⚠️  Realm '{REALM_NAME}' 없음. 생성 중...")
                # Realm 생성
                realm_payload = {
                    "realm": REALM_NAME,
                    "enabled": True,
                    "displayName": "Formation Lap",
                }
                
                create_response = await client.post(
                    f"{KEYCLOAK_URL}/admin/realms",
                    headers={
                        "Authorization": f"Bearer {admin_token}",
                        "Content-Type": "application/json"
                    },
                    json=realm_payload,
                )
                
                if create_response.status_code in [201, 409]:  # 409는 이미 존재하는 경우
                    print(f"✅ Realm '{REALM_NAME}' 생성 완료")
                else:
                    print(f"❌ Realm 생성 실패: {create_response.status_code}")
                    print(f"   응답: {create_response.text}")
                    return False
            else:
                print(f"❌ Realm 확인 실패: {realm_response.status_code}")
                print(f"   응답: {realm_response.text}")
                return False
            
            # 3. Client 존재 확인
            print(f"\\n3단계: Client '{CLIENT_ID}' 확인...")
            client_response = await client.get(
                f"{KEYCLOAK_URL}/admin/realms/{REALM_NAME}/clients",
                headers={
                    "Authorization": f"Bearer {admin_token}",
                    "Content-Type": "application/json"
                },
                params={"clientId": CLIENT_ID},
            )
            
            if client_response.status_code == 200:
                clients = client_response.json()
                if clients:
                    print(f"✅ Client '{CLIENT_ID}' 이미 존재")
                else:
                    print(f"⚠️  Client '{CLIENT_ID}' 없음. 생성 중...")
                    # Client 생성
                    client_payload = {
                        "clientId": CLIENT_ID,
                        "enabled": True,
                        "publicClient": True,  # Public client (no secret needed)
                        "standardFlowEnabled": True,
                        "directAccessGrantsEnabled": True,
                    }
                    
                    create_client_response = await client.post(
                        f"{KEYCLOAK_URL}/admin/realms/{REALM_NAME}/clients",
                        headers={
                            "Authorization": f"Bearer {admin_token}",
                            "Content-Type": "application/json"
                        },
                        json=client_payload,
                    )
                    
                    if create_client_response.status_code in [201, 409]:
                        print(f"✅ Client '{CLIENT_ID}' 생성 완료")
                    else:
                        print(f"❌ Client 생성 실패: {create_client_response.status_code}")
                        print(f"   응답: {create_client_response.text}")
            else:
                print(f"❌ Client 확인 실패: {client_response.status_code}")
                print(f"   응답: {client_response.text}")
            
            print("\\n" + "=" * 60)
            print("✅ Keycloak 설정 완료!")
            print("=" * 60)
            return True
            
    except httpx.ConnectError as e:
        print(f"❌ Keycloak 연결 실패: {e}")
        print(f"   Keycloak URL에 접근할 수 없습니다: {KEYCLOAK_URL}")
        return False
    except Exception as e:
        print(f"❌ 오류: {e}")
        import traceback
        traceback.print_exc()
        return False

# 실행
result = asyncio.run(setup_keycloak())
"""

commands = [
    "cd /root/Backend",
    "export PATH=$PATH:/root/.local/bin",
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
    print("15초 대기 중...")
    time.sleep(15)
    
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

#!/bin/bash
# Keycloak Realm 및 Client 설정 (직접 실행 버전)

KEYCLOAK_URL="https://api.matchacake.click/keycloak"
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="admin"
REALM_NAME="formation-lap"
CLIENT_ID="backend-client"

echo "============================================================"
echo "Keycloak Realm 및 Client 설정"
echo "============================================================"
echo "Keycloak URL: $KEYCLOAK_URL"
echo "Realm: $REALM_NAME"
echo "Client ID: $CLIENT_ID"
echo ""

# Python 스크립트 실행
python3 << 'PYEOF'
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
    print("\n1단계: Admin 토큰 가져오기...")
    try:
        async with httpx.AsyncClient(timeout=30.0, verify=False) as client:
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
            print(f"\n2단계: Realm '{REALM_NAME}' 확인...")
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
            print(f"\n3단계: Client '{CLIENT_ID}' 확인...")
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
            
            # 4. 테스트 사용자 생성
            print(f"\n4단계: 테스트 사용자 생성...")
            test_username = "testuser"
            test_password = "testuser123"
            
            # 사용자 존재 확인
            user_response = await client.get(
                f"{KEYCLOAK_URL}/admin/realms/{REALM_NAME}/users",
                headers={
                    "Authorization": f"Bearer {admin_token}",
                    "Content-Type": "application/json"
                },
                params={"username": test_username},
            )
            
            if user_response.status_code == 200:
                users = user_response.json()
                if users:
                    print(f"✅ 사용자 '{test_username}' 이미 존재")
                    user_id = users[0]["id"]
                else:
                    print(f"⚠️  사용자 '{test_username}' 없음. 생성 중...")
                    # 사용자 생성
                    user_payload = {
                        "username": test_username,
                        "email": f"{test_username}@example.com",
                        "enabled": True,
                        "emailVerified": True,
                        "firstName": "Test",
                        "lastName": "User"
                    }
                    
                    create_user_response = await client.post(
                        f"{KEYCLOAK_URL}/admin/realms/{REALM_NAME}/users",
                        headers={
                            "Authorization": f"Bearer {admin_token}",
                            "Content-Type": "application/json"
                        },
                        json=user_payload,
                    )
                    
                    if create_user_response.status_code in [201, 409]:
                        print(f"✅ 사용자 '{test_username}' 생성 완료")
                        
                        # 사용자 ID 가져오기
                        user_id_response = await client.get(
                            f"{KEYCLOAK_URL}/admin/realms/{REALM_NAME}/users",
                            headers={
                                "Authorization": f"Bearer {admin_token}",
                                "Content-Type": "application/json"
                            },
                            params={"username": test_username},
                        )
                        
                        if user_id_response.status_code == 200:
                            users = user_id_response.json()
                            if users:
                                user_id = users[0]["id"]
                            else:
                                print(f"❌ 사용자 ID를 가져올 수 없습니다")
                                return False
                        else:
                            print(f"❌ 사용자 ID 조회 실패: {user_id_response.status_code}")
                            return False
                    else:
                        print(f"❌ 사용자 생성 실패: {create_user_response.status_code}")
                        print(f"   응답: {create_user_response.text}")
                        return False
                
                # 비밀번호 설정 (기존 사용자도 비밀번호 재설정)
                print(f"\n5단계: 사용자 비밀번호 설정...")
                password_payload = {
                    "type": "password",
                    "value": test_password,
                    "temporary": False
                }
                
                password_response = await client.put(
                    f"{KEYCLOAK_URL}/admin/realms/{REALM_NAME}/users/{user_id}/reset-password",
                    headers={
                        "Authorization": f"Bearer {admin_token}",
                        "Content-Type": "application/json"
                    },
                    json=password_payload,
                )
                
                if password_response.status_code in [204, 200]:
                    print(f"✅ 사용자 비밀번호 설정 완료")
                    print(f"   Username: {test_username}")
                    print(f"   Password: {test_password}")
                else:
                    print(f"⚠️  비밀번호 설정 실패: {password_response.status_code}")
                    print(f"   응답: {password_response.text}")
            else:
                print(f"❌ 사용자 확인 실패: {user_response.status_code}")
                print(f"   응답: {user_response.text}")
            
            print("\n" + "=" * 60)
            print("✅ Keycloak 설정 완료!")
            print("=" * 60)
            print(f"\n테스트 사용자 정보:")
            print(f"  Username: {test_username}")
            print(f"  Password: {test_password}")
            print(f"\n토큰 발급 테스트:")
            print(f"  curl -X POST {KEYCLOAK_URL}/realms/{REALM_NAME}/protocol/openid-connect/token \\")
            print(f"    -H \"Content-Type: application/x-www-form-urlencoded\" \\")
            print(f"    -d \"grant_type=password&client_id={CLIENT_ID}&username={test_username}&password={test_password}\" \\")
            print(f"    -k | jq .")
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
PYEOF

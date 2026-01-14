#!/usr/bin/env python3
"""
RDS Proxy 인증 설정 수정 (올바른 구문)
"""
import subprocess
import json

REGION = "ap-northeast-2"
PROXY_NAME = "y2om-formation-lap-kor-rds-proxy"
SECRET_ARN = "arn:aws:secretsmanager:ap-northeast-2:404457776061:secret:formation-lap/db/dev/credentials-4rct3d"

print("=" * 60)
print("RDS Proxy 인증 설정 수정")
print("=" * 60)

# modify-db-proxy의 올바른 구문 확인
# --auth는 여러 번 지정할 수 있지만, 기존 auth를 교체하려면 전체 auth 설정을 다시 지정해야 함

print("\n옵션 1: RDS Proxy 수정 (올바른 구문)")
print("=" * 60)

# JSON 형식으로 auth 설정
auth_config = {
    "SecretArn": SECRET_ARN,
    "AuthScheme": "SECRETS",
    "IAMAuth": "DISABLED"
}

print(f"명령어:")
print(f"aws rds modify-db-proxy \\")
print(f"  --db-proxy-name {PROXY_NAME} \\")
print(f"  --region {REGION} \\")
print(f"  --auth SecretArn={SECRET_ARN},AuthScheme=SECRETS,IAMAuth=DISABLED")

print("\n" + "=" * 60)
print("옵션 2: Terraform으로 RDS Proxy 재생성")
print("=" * 60)
print("Terraform을 사용하여 RDS Proxy를 재생성하면 Secrets Manager를 다시 읽습니다.")
print("\n명령어:")
print("cd /root/Terraform/03-database")
print("terraform apply -target=module.database.aws_db_proxy.kor")

print("\n" + "=" * 60)
print("옵션 3: RDS 클러스터에 직접 연결 (Proxy 우회)")
print("=" * 60)
print("보안 그룹을 수정하여 Bastion -> RDS 클러스터 직접 연결을 허용하고,")
print(".env 파일에서 RDS 클러스터 엔드포인트를 사용하세요.")

print("\n" + "=" * 60)
print("권장 방법:")
print("=" * 60)
print("1. 먼저 옵션 1을 시도 (RDS Proxy 수정)")
print("2. 실패하면 옵션 2 (Terraform으로 재생성)")
print("3. 그래도 안 되면 옵션 3 (직접 연결)")

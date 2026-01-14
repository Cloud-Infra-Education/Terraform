#!/usr/bin/env python3
"""
RDS 클러스터 마스터 비밀번호 확인 및 업데이트
"""
import subprocess
import json

REGION = "ap-northeast-2"
CLUSTER_ID = "y2om-kor-aurora-mysql"
NEW_PASSWORD = "StrongPassword123!"

print("=" * 60)
print("RDS 클러스터 마스터 비밀번호 확인")
print("=" * 60)

# 1. RDS 클러스터 정보 확인
print("\n1단계: RDS 클러스터 정보 확인...")
cmd = [
    "aws", "rds", "describe-db-clusters",
    "--db-cluster-identifier", CLUSTER_ID,
    "--region", REGION,
    "--query", "DBClusters[0].[MasterUsername,Status]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    username = data[0]
    status = data[1]
    print(f"✅ 클러스터 확인 성공")
    print(f"   Master Username: {username}")
    print(f"   Status: {status}")
    
    # 2. 마스터 비밀번호 수정
    print("\n2단계: 마스터 비밀번호 수정...")
    cmd_modify = [
        "aws", "rds", "modify-db-cluster",
        "--db-cluster-identifier", CLUSTER_ID,
        "--region", REGION,
        "--master-user-password", NEW_PASSWORD,
        "--apply-immediately",
        "--output", "json"
    ]
    
    try:
        result = subprocess.run(cmd_modify, capture_output=True, text=True, check=True)
        print(f"✅ 마스터 비밀번호 수정 성공!")
        print(f"   클러스터 상태가 'available'이 될 때까지 기다려야 합니다.")
        print(f"   (보통 1-2분 소요)")
    except subprocess.CalledProcessError as e:
        print(f"❌ 마스터 비밀번호 수정 실패: {e.stderr}")
        if "InvalidParameterValue" in e.stderr:
            print(f"\n⚠️  비밀번호가 이미 동일할 수 있습니다.")
        else:
            print(f"\n수동으로 수정하세요:")
            print(f"aws rds modify-db-cluster \\")
            print(f"  --db-cluster-identifier {CLUSTER_ID} \\")
            print(f"  --region {REGION} \\")
            print(f"  --master-user-password {NEW_PASSWORD} \\")
            print(f"  --apply-immediately")
    
except subprocess.CalledProcessError as e:
    print(f"❌ 클러스터 확인 실패: {e.stderr}")
except Exception as e:
    print(f"❌ 오류: {e}")

print("\n" + "=" * 60)
print("완료!")
print("=" * 60)
print("\n비밀번호 수정 후 1-2분 기다린 다음 다시 연결을 시도하세요.")

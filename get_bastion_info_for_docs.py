#!/usr/bin/env python3
"""
Bastion 정보 확인 및 docs 접근 방법 안내
"""
import subprocess
import json

REGION = "ap-northeast-2"
INSTANCE_ID = "i-0088889a043f54312"

print("=" * 60)
print("Bastion 정보 확인 및 API Docs 접근 방법")
print("=" * 60)

# 1. Bastion Public IP 확인
print("\n1단계: Bastion Public IP 확인...")
cmd = [
    "aws", "ec2", "describe-instances",
    "--instance-ids", INSTANCE_ID,
    "--region", REGION,
    "--query", "Reservations[0].Instances[0].[PublicIpAddress,PublicDnsName]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    data = json.loads(result.stdout)
    public_ip = data[0]
    public_dns = data[1]
    
    print(f"✅ Public IP: {public_ip}")
    print(f"✅ Public DNS: {public_dns}")
except Exception as e:
    print(f"❌ 확인 실패: {e}")
    public_ip = None
    public_dns = None

# 2. 보안 그룹 확인
print("\n2단계: 보안 그룹 확인...")
cmd = [
    "aws", "ec2", "describe-instances",
    "--instance-ids", INSTANCE_ID,
    "--region", REGION,
    "--query", "Reservations[0].Instances[0].SecurityGroups[0].GroupId",
    "--output", "text"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    sg_id = result.stdout.strip()
    
    print(f"✅ Security Group ID: {sg_id}")
    
    # 보안 그룹 규칙 확인 (포트 8000)
    cmd_sg = [
        "aws", "ec2", "describe-security-groups",
        "--group-ids", sg_id,
        "--region", REGION,
        "--query", "SecurityGroups[0].IpPermissions[?FromPort==`8000` || ToPort==`8000`]",
        "--output", "json"
    ]
    
    result = subprocess.run(cmd_sg, capture_output=True, text=True, check=True)
    rules = json.loads(result.stdout)
    
    if rules:
        print(f"✅ 포트 8000 규칙이 있습니다:")
        for rule in rules:
            print(f"   - {rule}")
    else:
        print(f"⚠️  포트 8000 규칙이 없습니다. 보안 그룹에 규칙을 추가해야 합니다.")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 3. 접근 방법 안내
print("\n" + "=" * 60)
print("API Docs 접근 방법:")
print("=" * 60)

if public_ip:
    print(f"\n1. 직접 접근 (보안 그룹에서 포트 8000 허용 필요):")
    print(f"   Swagger UI: http://{public_ip}:8000/docs")
    print(f"   ReDoc: http://{public_ip}:8000/redoc")
    print(f"   또는 DNS: http://{public_dns}:8000/docs")
    
    print(f"\n2. SSH 터널링 (로컬 머신에서):")
    print(f"   ssh -i ~/.ssh/KeyPair-Seoul.pem -L 8000:localhost:8000 ec2-user@{public_ip}")
    print(f"   그 후 브라우저에서: http://localhost:8000/docs")
    
    print(f"\n3. SSM Session Manager 포트 포워딩 (로컬 머신에서):")
    print(f"   aws ssm start-session \\")
    print(f"     --target {INSTANCE_ID} \\")
    print(f"     --region {REGION} \\")
    print(f"     --document-name AWS-StartPortForwardingSession \\")
    print(f"     --parameters '{{\"portNumber\":[\"8000\"],\"localPortNumber\":[\"8000\"]}}'")
    print(f"   그 후 브라우저에서: http://localhost:8000/docs")
else:
    print("⚠️  Public IP를 확인할 수 없습니다.")

print("\n" + "=" * 60)
print("보안 그룹 규칙 추가 (필요시):")
print("=" * 60)
print("포트 8000을 외부에서 접근하려면 보안 그룹에 다음 규칙을 추가하세요:")
print(f"aws ec2 authorize-security-group-ingress \\")
print(f"  --group-id {sg_id if 'sg_id' in locals() else '<SECURITY_GROUP_ID>'} \\")
print(f"  --protocol tcp \\")
print(f"  --port 8000 \\")
print(f"  --cidr 0.0.0.0/0 \\")
print(f"  --region {REGION}")

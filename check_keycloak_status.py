#!/usr/bin/env python3
"""
Keycloak 배포 상태 확인
"""
import subprocess
import json

REGION = "ap-northeast-2"
CLUSTER_NAME = "y2om-formation-lap-seoul-eks"  # 실제 클러스터 이름으로 변경 필요

print("=" * 60)
print("Keycloak 배포 상태 확인")
print("=" * 60)

# 1. EKS 클러스터 이름 확인
print("\n1단계: EKS 클러스터 목록 확인...")
cmd = [
    "aws", "eks", "list-clusters",
    "--region", REGION,
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    clusters = json.loads(result.stdout).get('clusters', [])
    print(f"✅ EKS 클러스터: {clusters}")
    
    if clusters:
        cluster_name = clusters[0]
        print(f"\n2단계: Keycloak Pod 상태 확인 (클러스터: {cluster_name})...")
        print("\n다음 명령어를 실행하세요:")
        print(f"aws eks update-kubeconfig --region {REGION} --name {cluster_name}")
        print("kubectl get pods -n formation-lap | grep keycloak")
        print("kubectl get svc -n formation-lap | grep keycloak")
        print("kubectl get ingress -n formation-lap | grep keycloak")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 2. ALB 상태 확인
print("\n3단계: Keycloak ALB 상태 확인...")
cmd = [
    "aws", "elbv2", "describe-load-balancers",
    "--region", REGION,
    "--query", "LoadBalancers[?contains(LoadBalancerName, 'keycloak')].[LoadBalancerName,DNSName,State.Code]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    albs = json.loads(result.stdout)
    if albs:
        print("✅ Keycloak ALB:")
        for alb in albs:
            print(f"   - 이름: {alb[0]}")
            print(f"   - DNS: {alb[1]}")
            print(f"   - 상태: {alb[2]}")
    else:
        print("⚠️  Keycloak ALB를 찾을 수 없습니다")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

# 3. Route53 레코드 확인
print("\n4단계: Route53 레코드 확인...")
cmd = [
    "aws", "route53", "list-resource-record-sets",
    "--hosted-zone-id", "Z038651135MZFV9GL29ON",
    "--query", "ResourceRecordSets[?contains(Name, 'keycloak')].[Name,Type,ResourceRecords[0].Value]",
    "--output", "json"
]

try:
    result = subprocess.run(cmd, capture_output=True, text=True, check=True)
    records = json.loads(result.stdout)
    if records:
        print("✅ Keycloak Route53 레코드:")
        for record in records:
            print(f"   - {record[0]} ({record[1]}) -> {record[2] if len(record) > 2 else 'N/A'}")
    else:
        print("⚠️  Keycloak Route53 레코드를 찾을 수 없습니다")
except Exception as e:
    print(f"❌ 확인 실패: {e}")

print("\n" + "=" * 60)
print("해결 방법:")
print("=" * 60)
print("1. Keycloak이 Kubernetes에 배포되어 있는지 확인")
print("2. Keycloak Ingress가 생성되어 있는지 확인")
print("3. Keycloak ALB가 생성되어 있는지 확인")
print("4. Route53 레코드가 올바르게 설정되어 있는지 확인")
print("\nKeycloak이 배포되지 않았다면 Terraform으로 배포해야 합니다.")

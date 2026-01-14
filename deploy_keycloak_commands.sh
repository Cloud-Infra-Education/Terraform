#!/bin/bash
# Keycloak 배포 명령어

REGION="ap-northeast-2"

echo "============================================================"
echo "Keycloak 배포"
echo "============================================================"

# 1. EKS 클러스터 이름 확인
echo ""
echo "1단계: EKS 클러스터 목록 확인..."
aws eks list-clusters --region $REGION --query 'clusters[]' --output text

# 첫 번째 클러스터 사용
CLUSTER_NAME=$(aws eks list-clusters --region $REGION --query 'clusters[0]' --output text)
echo "사용할 클러스터: $CLUSTER_NAME"

# 2. kubeconfig 업데이트
echo ""
echo "2단계: kubeconfig 업데이트..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# 3. namespace 생성 (없는 경우)
echo ""
echo "3단계: namespace 확인/생성..."
kubectl create namespace formation-lap --dry-run=client -o yaml | kubectl apply -f -

# 4. Keycloak 배포
echo ""
echo "4단계: Keycloak 배포..."
kubectl apply -f /root/Terraform/keycloak-deployment.yaml

# 5. 배포 상태 확인
echo ""
echo "5단계: 배포 상태 확인..."
kubectl get pods -n formation-lap -l app=keycloak
kubectl get svc -n formation-lap | grep keycloak
kubectl get ingress -n formation-lap | grep keycloak

echo ""
echo "============================================================"
echo "Keycloak Pod가 준비될 때까지 기다리는 중..."
echo "============================================================"
kubectl wait --for=condition=ready pod -l app=keycloak -n formation-lap --timeout=300s || echo "⚠️  Pod 준비 대기 시간 초과"

echo ""
echo "============================================================"
echo "Keycloak 로그 확인 (최근 20줄)"
echo "============================================================"
kubectl logs -n formation-lap -l app=keycloak --tail=20

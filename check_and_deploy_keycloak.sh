#!/bin/bash
# Keycloak 배포 상태 확인 및 배포

REGION="ap-northeast-2"

echo "============================================================"
echo "Keycloak 배포 상태 확인 및 배포"
echo "============================================================"

# 1. EKS 클러스터 이름 확인
echo ""
echo "1단계: EKS 클러스터 목록 확인..."
CLUSTERS=$(aws eks list-clusters --region $REGION --query 'clusters[]' --output text)
echo "클러스터: $CLUSTERS"

if [ -z "$CLUSTERS" ]; then
    echo "❌ EKS 클러스터를 찾을 수 없습니다"
    exit 1
fi

CLUSTER_NAME=$(echo $CLUSTERS | awk '{print $1}')
echo "사용할 클러스터: $CLUSTER_NAME"

# 2. kubeconfig 업데이트
echo ""
echo "2단계: kubeconfig 업데이트..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# 3. Keycloak Pod 상태 확인
echo ""
echo "3단계: Keycloak Pod 상태 확인..."
kubectl get pods -n formation-lap | grep keycloak || echo "⚠️  Keycloak Pod를 찾을 수 없습니다"

# 4. Keycloak Service 확인
echo ""
echo "4단계: Keycloak Service 확인..."
kubectl get svc -n formation-lap | grep keycloak || echo "⚠️  Keycloak Service를 찾을 수 없습니다"

# 5. Keycloak Ingress 확인
echo ""
echo "5단계: Keycloak Ingress 확인..."
kubectl get ingress -n formation-lap | grep keycloak || echo "⚠️  Keycloak Ingress를 찾을 수 없습니다"

# 6. Keycloak 배포 (없는 경우)
echo ""
echo "6단계: Keycloak 배포..."
if ! kubectl get deployment keycloak -n formation-lap &>/dev/null; then
    echo "Keycloak이 배포되지 않았습니다. 배포를 시작합니다..."
    kubectl apply -f /root/Terraform/keycloak-deployment.yaml
    echo "✅ Keycloak 배포 완료!"
    echo "Pod가 준비될 때까지 기다리는 중..."
    kubectl wait --for=condition=ready pod -l app=keycloak -n formation-lap --timeout=300s || echo "⚠️  Pod 준비 대기 시간 초과"
else
    echo "✅ Keycloak이 이미 배포되어 있습니다"
fi

# 7. 최종 상태 확인
echo ""
echo "============================================================"
echo "최종 상태 확인"
echo "============================================================"
kubectl get pods,svc,ingress -n formation-lap | grep keycloak

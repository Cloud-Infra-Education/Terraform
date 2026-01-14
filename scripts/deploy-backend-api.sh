#!/bin/bash
# Backend API 배포 자동화 스크립트

set -e

echo "=== Backend API 파드 배포 시작 ==="
echo ""

# 1. ECR 리포지토리 생성
echo "1. ECR 리포지토리 확인/생성..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="${ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/backend-api"

aws ecr create-repository \
  --repository-name backend-api \
  --region ap-northeast-2 2>/dev/null || echo "✅ 리포지토리가 이미 존재합니다"

echo "ECR Repository: $ECR_REPO"
echo ""

# 2. Docker 이미지 빌드
echo "2. Docker 이미지 빌드..."
cd /root/Backend
docker build -t backend-api:latest . || {
    echo "❌ Docker 빌드 실패"
    exit 1
}
echo "✅ 이미지 빌드 완료"
echo ""

# 3. ECR에 로그인
echo "3. ECR 로그인..."
aws ecr get-login-password --region ap-northeast-2 | \
  docker login --username AWS --password-stdin $ECR_REPO || {
    echo "❌ ECR 로그인 실패"
    exit 1
}
echo "✅ ECR 로그인 완료"
echo ""

# 4. 이미지 푸시
echo "4. 이미지 푸시..."
docker tag backend-api:latest $ECR_REPO:latest
docker push $ECR_REPO:latest || {
    echo "❌ 이미지 푸시 실패"
    exit 1
}
echo "✅ 이미지 푸시 완료"
echo ""

# 5. Terraform 변수 확인 및 설정
echo "5. Terraform 변수 확인..."
cd /root/Terraform

# terraform.tfvars 파일 확인
if [ ! -f terraform.tfvars ]; then
    echo "⚠️  terraform.tfvars 파일이 없습니다. 생성합니다..."
    touch terraform.tfvars
fi

# ECR URL이 있는지 확인하고 없으면 추가
if ! grep -q "ecr_repository_url" terraform.tfvars; then
    echo "⚠️  terraform.tfvars에 ecr_repository_url 추가 중..."
    echo "ecr_repository_url = \"$ECR_REPO\"" >> terraform.tfvars
    echo "✅ ecr_repository_url 추가 완료"
else
    # 기존 값이 있으면 업데이트
    if grep -q "ecr_repository_url.*=" terraform.tfvars; then
        echo "✅ ecr_repository_url이 이미 설정되어 있습니다"
    fi
fi

# 다른 필요한 변수들도 확인
if ! grep -q "^db_name" terraform.tfvars; then
    echo "db_name = \"y2om_db\"" >> terraform.tfvars
fi

if ! grep -q "^keycloak_admin_username" terraform.tfvars; then
    echo "keycloak_admin_username = \"admin\"" >> terraform.tfvars
fi

if ! grep -q "^keycloak_admin_password" terraform.tfvars; then
    echo "keycloak_admin_password = \"admin\"" >> terraform.tfvars
fi

if ! grep -q "^meilisearch_api_key" terraform.tfvars; then
    echo "meilisearch_api_key = \"masterKey123\"" >> terraform.tfvars
fi

echo ""

# 6. Terraform 적용
echo "6. Terraform 적용 (Backend 배포)..."
terraform init -upgrade || {
    echo "❌ Terraform init 실패"
    exit 1
}

echo ""
echo "=== Terraform Plan ==="
terraform plan -target=module.domain.kubernetes_deployment_v1.backend_api_seoul \
              -target=module.domain.kubernetes_service_v1.backend_api_service_seoul \
              -target=module.domain.kubernetes_config_map_v1.backend_config_seoul \
              -target=module.domain.kubernetes_secret_v1.backend_secrets_seoul

echo ""
echo "=== Terraform Apply ==="
terraform apply -auto-approve \
    -target=module.domain.kubernetes_deployment_v1.backend_api_seoul \
    -target=module.domain.kubernetes_service_v1.backend_api_service_seoul \
    -target=module.domain.kubernetes_config_map_v1.backend_config_seoul \
    -target=module.domain.kubernetes_secret_v1.backend_secrets_seoul || {
    echo "❌ Terraform apply 실패"
    exit 1
}
echo "✅ Terraform 적용 완료"
echo ""

# 7. 배포 확인
echo "7. 배포 상태 확인..."
sleep 15  # 파드 생성 대기

echo ""
echo "=== 파드 상태 ==="
kubectl get pods -n formation-lap -l app=backend-api || echo "파드를 찾을 수 없습니다"

echo ""
echo "=== 서비스 상태 ==="
kubectl get svc -n formation-lap backend-api-service || echo "서비스를 찾을 수 없습니다"

echo ""
echo "=== 파드 로그 (최근 30줄) ==="
kubectl logs -n formation-lap -l app=backend-api --tail=30 2>/dev/null || echo "로그를 가져올 수 없습니다 (파드가 아직 시작 중일 수 있음)"

echo ""
echo "=== 배포 완료! ==="
echo ""
echo "다음 명령어로 상태를 확인하세요:"
echo "  kubectl get pods -n formation-lap -l app=backend-api"
echo "  kubectl logs -n formation-lap -l app=backend-api --tail=50"
echo "  kubectl describe pod -n formation-lap -l app=backend-api"
echo ""
echo "ECR Repository: $ECR_REPO"

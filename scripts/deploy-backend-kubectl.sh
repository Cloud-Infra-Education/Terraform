#!/bin/bash
# kubectl을 사용한 Backend API 배포 (Terraform 대신)

set -e

echo "=== kubectl을 사용한 Backend API 배포 ==="
echo ""

# ECR 정보 가져오기
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
ECR_REPO="${ACCOUNT_ID}.dkr.ecr.ap-northeast-2.amazonaws.com/backend-api"

# Terraform output에서 필요한 정보 가져오기
echo "1. Terraform output에서 정보 가져오기..."
cd /root/Terraform

# RDS Proxy endpoint
RDS_PROXY_ENDPOINT=$(terraform output -raw kor_db_proxy_endpoint 2>/dev/null || echo "")
if [ -z "$RDS_PROXY_ENDPOINT" ]; then
    echo "⚠️  RDS Proxy endpoint를 찾을 수 없습니다. 직접 입력하세요:"
    read -p "RDS Proxy endpoint: " RDS_PROXY_ENDPOINT
fi

# Database 정보
DB_USER=$(grep "^db_username" terraform.tfvars | cut -d'"' -f2 || echo "admin")
DB_PASSWORD=$(grep "^db_password" terraform.tfvars | cut -d'"' -f2 || echo "")
DB_NAME=$(grep "^db_name" terraform.tfvars | cut -d'"' -f2 || echo "y2om_db")

if [ -z "$DB_PASSWORD" ]; then
    echo "⚠️  Database password를 입력하세요:"
    read -s -p "DB Password: " DB_PASSWORD
    echo ""
fi

echo "✅ 설정 정보:"
echo "   ECR Repository: $ECR_REPO"
echo "   RDS Proxy: $RDS_PROXY_ENDPOINT"
echo "   DB Name: $DB_NAME"
echo ""

# Namespace 확인
echo "2. Namespace 확인..."
kubectl get namespace formation-lap 2>/dev/null || kubectl create namespace formation-lap
echo ""

# ConfigMap 생성
echo "3. ConfigMap 생성..."
kubectl create configmap backend-config -n formation-lap \
  --from-literal=APP_NAME="Backend API" \
  --from-literal=APP_VERSION="1.0.0" \
  --from-literal=DEBUG="false" \
  --from-literal=ENVIRONMENT="production" \
  --from-literal=HOST="0.0.0.0" \
  --from-literal=PORT="8000" \
  --from-literal=KEYCLOAK_URL="https://api.matchacake.click/keycloak" \
  --from-literal=KEYCLOAK_REALM="formation-lap" \
  --from-literal=KEYCLOAK_CLIENT_ID="backend-client" \
  --from-literal=JWT_ALGORITHM="RS256" \
  --from-literal=MEILISEARCH_URL="http://meilisearch-service:7700" \
  --from-literal=DB_PORT="3306" \
  --from-literal=DB_NAME="$DB_NAME" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "✅ ConfigMap 생성 완료"
echo ""

# Secret 생성
echo "4. Secret 생성..."
DATABASE_URL="mysql+pymysql://${DB_USER}:${DB_PASSWORD}@${RDS_PROXY_ENDPOINT}:3306/${DB_NAME}?charset=utf8mb4"

kubectl create secret generic backend-secrets -n formation-lap \
  --from-literal=KEYCLOAK_CLIENT_SECRET="" \
  --from-literal=KEYCLOAK_ADMIN_USERNAME="admin" \
  --from-literal=KEYCLOAK_ADMIN_PASSWORD="admin" \
  --from-literal=MEILISEARCH_API_KEY="masterKey123" \
  --from-literal=DATABASE_URL="$DATABASE_URL" \
  --dry-run=client -o yaml | kubectl apply -f -
echo "✅ Secret 생성 완료"
echo ""

# Deployment 생성
echo "5. Deployment 생성..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend-api
  namespace: formation-lap
  labels:
    app: backend-api
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend-api
  template:
    metadata:
      labels:
        app: backend-api
    spec:
      containers:
      - name: backend-api
        image: ${ECR_REPO}:latest
        ports:
        - containerPort: 8000
          name: http
        envFrom:
        - configMapRef:
            name: backend-config
        - secretRef:
            name: backend-secrets
        resources:
          requests:
            cpu: 200m
            memory: 512Mi
          limits:
            cpu: 1000m
            memory: 1Gi
        readinessProbe:
          httpGet:
            path: /api/v1/health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        livenessProbe:
          httpGet:
            path: /api/v1/health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 30
          timeoutSeconds: 5
          failureThreshold: 3
EOF
echo "✅ Deployment 생성 완료"
echo ""

# Service 생성
echo "6. Service 생성..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: backend-api-service
  namespace: formation-lap
  labels:
    app: backend-api
spec:
  type: ClusterIP
  selector:
    app: backend-api
  ports:
  - port: 8000
    targetPort: 8000
    protocol: TCP
    name: http
EOF
echo "✅ Service 생성 완료"
echo ""

# 배포 확인
echo "7. 배포 상태 확인..."
sleep 10

echo ""
echo "=== 파드 상태 ==="
kubectl get pods -n formation-lap -l app=backend-api

echo ""
echo "=== 서비스 상태 ==="
kubectl get svc -n formation-lap backend-api-service

echo ""
echo "=== 배포 완료! ==="

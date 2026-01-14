#!/bin/bash
# 데이터베이스 비밀번호 확인 및 비교 스크립트

echo "=== 데이터베이스 비밀번호 확인 및 비교 ==="
echo ""

cd /root/Terraform

# 1. terraform.tfvars에서 db_password 확인
echo "1. terraform.tfvars에서 db_password 확인..."
TFVARS_PASSWORD=$(grep "^db_password" terraform.tfvars 2>/dev/null | cut -d'"' -f2)

if [ -z "$TFVARS_PASSWORD" ]; then
    echo "   ⚠️  terraform.tfvars에서 db_password를 찾을 수 없습니다"
    echo "   파일 확인: cat terraform.tfvars | grep db_password"
else
    echo "   ✅ terraform.tfvars db_password: $TFVARS_PASSWORD"
fi
echo ""

# 2. Secrets Manager 비밀번호 확인
echo "2. Secrets Manager 비밀번호 확인..."
SECRETS_PASSWORD=$(aws secretsmanager get-secret-value \
  --region ap-northeast-2 \
  --secret-id formation-lap/db/dev/credentials \
  --query SecretString --output text 2>/dev/null | jq -r '.password' 2>/dev/null)

if [ -z "$SECRETS_PASSWORD" ]; then
    echo "   ⚠️  Secrets Manager에서 비밀번호를 가져올 수 없습니다"
else
    echo "   ✅ Secrets Manager password: $SECRETS_PASSWORD"
fi
echo ""

# 3. Backend 파드 DATABASE_URL 비밀번호 확인
echo "3. Backend 파드 DATABASE_URL 비밀번호 확인..."
POD_NAME=$(kubectl get pods -n formation-lap -l app=backend-api -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -n "$POD_NAME" ]; then
    POD_PASSWORD=$(kubectl exec -n formation-lap $POD_NAME -- env 2>/dev/null | grep DATABASE_URL | cut -d'@' -f1 | cut -d':' -f3 | cut -d'/' -f1)
    if [ -n "$POD_PASSWORD" ]; then
        echo "   ✅ Backend 파드 password: $POD_PASSWORD"
    else
        echo "   ⚠️  Backend 파드에서 비밀번호를 가져올 수 없습니다"
    fi
else
    echo "   ⚠️  Backend 파드를 찾을 수 없습니다"
fi
echo ""

# 4. 비교
echo "=== 비밀번호 비교 ==="
if [ -n "$TFVARS_PASSWORD" ] && [ -n "$SECRETS_PASSWORD" ]; then
    if [ "$TFVARS_PASSWORD" = "$SECRETS_PASSWORD" ]; then
        echo "✅ terraform.tfvars와 Secrets Manager 비밀번호 일치!"
    else
        echo "❌ terraform.tfvars와 Secrets Manager 비밀번호 불일치!"
        echo "   terraform.tfvars: $TFVARS_PASSWORD"
        echo "   Secrets Manager: $SECRETS_PASSWORD"
        echo ""
        echo "⚠️  해결 방법: Secrets Manager 비밀번호를 terraform.tfvars 값으로 업데이트"
    fi
else
    echo "⚠️  비교할 수 없습니다 (값이 없음)"
fi
echo ""

# 5. 요약
echo "=== 확인해야 할 파일 ==="
echo "1. /root/Terraform/terraform.tfvars"
echo "   - 변수: db_password"
echo "   - 확인: cat terraform.tfvars | grep db_password"
echo ""
echo "2. Secrets Manager"
echo "   - Secret 이름: formation-lap/db/dev/credentials"
echo "   - 확인: aws secretsmanager get-secret-value --secret-id formation-lap/db/dev/credentials --region ap-northeast-2"
echo ""
echo "3. DB 클러스터 생성 코드"
echo "   - 파일: /root/Terraform/modules/database/main.tf"
echo "   - 리소스: aws_rds_cluster.kor (master_password = var.db_password)"

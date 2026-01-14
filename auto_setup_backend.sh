#!/bin/bash
# Bastion 호스트에서 Backend 자동 설정 스크립트
# SSM Session Manager를 통해 실행

INSTANCE_ID="i-0088889a043f54312"
REGION="ap-northeast-2"

echo "============================================================"
echo "Bastion 호스트에서 Backend 자동 설정"
echo "============================================================"
echo ""

# 1단계: 필요한 도구 설치
echo "1단계: 필요한 도구 설치 중..."
COMMAND_ID=$(aws ssm send-command \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=[
    "sudo yum update -y",
    "sudo yum install -y python3 python3-pip git mysql",
    "python3 --version",
    "pip3 --version"
  ]' \
  --output text \
  --query 'Command.CommandId')

echo "Command ID: $COMMAND_ID"
echo "명령어 실행 중... (30초 대기)"
sleep 30

# 결과 확인
echo ""
echo "설치 결과:"
aws ssm get-command-invocation \
  --command-id $COMMAND_ID \
  --instance-id $INSTANCE_ID \
  --region $REGION \
  --query '[Status,StandardOutputContent]' \
  --output text

echo ""
echo "2단계: Backend 디렉토리 생성 및 환경 변수 설정..."
COMMAND_ID2=$(aws ssm send-command \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=[
    "cd ~",
    "mkdir -p Backend",
    "cd Backend",
    "cat > .env <<\"ENVEOF\"
# Database (RDS Proxy 엔드포인트)
DB_HOST=y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com
DB_PORT=3306
DB_USER=admin
DB_PASSWORD=StrongPassword123!
DB_NAME=formation_lap

# Database URL
DATABASE_URL=mysql+pymysql://admin:StrongPassword123!@y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com:3306/formation_lap

# Keycloak
KEYCLOAK_URL=http://keycloak-service:8080
KEYCLOAK_REALM=formation-lap
KEYCLOAK_CLIENT_ID=backend-client

# Meilisearch
MEILISEARCH_URL=http://meilisearch-service:7700
MEILISEARCH_API_KEY=masterKey123

# 기타
DEBUG=false
ENVIRONMENT=production
ENVEOF
",
    "chmod 600 .env",
    "pwd",
    "ls -la"
  ]' \
  --output text \
  --query 'Command.CommandId')

echo "Command ID: $COMMAND_ID2"
echo "명령어 실행 중... (10초 대기)"
sleep 10

# 결과 확인
echo ""
echo "환경 변수 설정 결과:"
aws ssm get-command-invocation \
  --command-id $COMMAND_ID2 \
  --instance-id $INSTANCE_ID \
  --region $REGION \
  --query '[Status,StandardOutputContent]' \
  --output text

echo ""
echo "============================================================"
echo "다음 단계"
echo "============================================================"
echo ""
echo "Backend 코드를 전송해야 합니다. 다음 중 하나를 선택하세요:"
echo ""
echo "옵션 1: SCP로 전송 (SSH 키 필요)"
echo "  cd /root/Terraform"
echo "  ./copy_backend_to_bastion.sh"
echo ""
echo "옵션 2: Git에서 클론 (SSM Session Manager에서)"
echo "  aws ssm start-session --target $INSTANCE_ID --region $REGION"
echo "  cd ~/Backend"
echo "  git clone <your-backend-repo-url> ."
echo ""
echo "옵션 3: 수동으로 파일 전송"
echo "  SSM Session Manager로 접속하여 직접 설정"
echo ""

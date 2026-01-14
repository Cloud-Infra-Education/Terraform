# VPC 내에서 Backend 실행하기

## 개요
Backend 애플리케이션을 VPC 내 Bastion 호스트에서 실행하여 RDS Proxy를 통해 데이터베이스에 접근할 수 있도록 설정합니다.

## 설정 완료 사항

### 1. 보안 그룹 규칙 추가
- ✅ Bastion 보안 그룹 ID를 VPC 모듈에서 출력
- ✅ Database 모듈에 Bastion 보안 그룹 변수 추가
- ✅ RDS Proxy 보안 그룹에 Bastion 인바운드 규칙 추가 (포트 3306)

### 2. Terraform 적용
변경 사항을 적용하려면 다음 명령을 실행하세요:

```bash
cd /root/Terraform
terraform apply
```

## VPC 내에서 Backend 실행 방법

### 1. Bastion 호스트 접속

**Seoul 리전:**
```bash
# Bastion Public IP 확인
cd /root/Terraform
terraform output -json | jq -r '.kor_bastion_public_ip.value'

# SSH 접속
ssh -i ~/.ssh/your-key.pem ec2-user@<BASTION_PUBLIC_IP>
```

**Oregon 리전:**
```bash
terraform output -json | jq -r '.usa_bastion_public_ip.value'
```

### 2. Bastion에서 Backend 설정

Bastion 호스트에 접속한 후:

```bash
# Python 및 필요한 도구 설치
sudo yum update -y
sudo yum install -y python3 python3-pip git docker

# Backend 코드 복사 (또는 git clone)
# Option 1: 로컬에서 SCP로 전송
# scp -r /root/Backend ec2-user@<BASTION_IP>:~/Backend

# Option 2: Git에서 클론
git clone <your-backend-repo>
cd Backend

# 의존성 설치
pip3 install -r requirements.txt
```

### 3. 환경 변수 설정

Bastion에서 `.env` 파일 설정:

```bash
# .env 파일 생성
cat > .env <<EOF
# Database (RDS Proxy 엔드포인트 사용)
DB_HOST=y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com
DB_PORT=3306
DB_USER=<your-db-username>
DB_PASSWORD=<your-db-password>
DB_NAME=<your-db-name>

# Keycloak
KEYCLOAK_URL=http://keycloak-service:8080
KEYCLOAK_REALM=<your-realm>
KEYCLOAK_CLIENT_ID=<your-client-id>

# Meilisearch
MEILISEARCH_URL=http://meilisearch-service:7700
MEILISEARCH_API_KEY=masterKey123

# 기타
DEBUG=false
EOF
```

### 4. Backend 서버 실행

```bash
# 서버 실행
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000

# 또는 백그라운드 실행
nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &
```

### 5. 연결 테스트

Bastion에서:

```bash
# Health check
curl http://localhost:8000/api/v1/health

# 토큰 발급 테스트
python3 get_token.py
```

## 네트워크 흐름

```
Bastion (Public Subnet)
  ↓
RDS Proxy (Private Subnet - DB Layer)
  ↓
Aurora MySQL (Private Subnet - DB Layer)
```

## 보안 그룹 규칙

### RDS Proxy 보안 그룹 인바운드
- **EKS Workers** (3306): 프로덕션 애플리케이션
- **Bastion** (3306): 개발/테스트 목적

### Bastion 보안 그룹
- **인바운드**: SSH (22) - 관리자 IP만
- **아웃바운드**: 모든 트래픽 허용

## 문제 해결

### DB 연결 실패
1. 보안 그룹 규칙이 올바르게 적용되었는지 확인:
   ```bash
   aws ec2 describe-security-groups --group-ids <proxy-sg-id> --region ap-northeast-2
   ```

2. RDS Proxy 엔드포인트가 올바른지 확인:
   ```bash
   aws rds describe-db-proxies --region ap-northeast-2
   ```

3. 네트워크 연결 테스트:
   ```bash
   # Bastion에서 RDS Proxy 연결 테스트
   mysql -h <rds-proxy-endpoint> -u <username> -p
   ```

### Keycloak/Meilisearch 연결
- Keycloak와 Meilisearch는 EKS 클러스터 내에서 실행 중일 가능성이 높습니다
- VPC 내부 DNS 또는 서비스 엔드포인트를 사용해야 합니다
- 또는 Docker Compose로 로컬에 실행할 수 있습니다

## 다음 단계

1. Terraform apply 실행하여 보안 그룹 규칙 적용
2. Bastion 호스트 접속
3. Backend 코드 배포
4. 서비스 연결 확인 및 테스트

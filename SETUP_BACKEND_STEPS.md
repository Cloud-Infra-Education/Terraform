# Bastion 호스트에서 Backend 설정 단계별 가이드

## 현재 상태
- ✅ SSM Session Manager 접속 성공
- ✅ IAM 역할 연결 완료
- ✅ SSM Agent Online

## 설정 단계

### 1. SSM Session Manager로 접속

```bash
aws ssm start-session --target i-0088889a043f54312 --region ap-northeast-2
```

### 2. 필요한 도구 설치

접속 후 다음 명령어 실행:

```bash
sudo yum update -y
sudo yum install -y python3 python3-pip git mysql
python3 --version
pip3 --version
```

### 3. Backend 디렉토리 생성

```bash
cd ~
mkdir -p Backend
cd Backend
```

### 4. 환경 변수 설정 (.env 파일 생성)

```bash
cat > .env <<'EOF'
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
EOF

chmod 600 .env
```

### 5. Backend 코드 배포

**옵션 A: Git에서 클론 (권장)**

```bash
# Git 저장소 URL을 알고 있는 경우
git clone <your-backend-repo-url> .
```

**옵션 B: SCP로 전송 (다른 터미널에서)**

로컬 머신에서:
```bash
cd /root/Terraform
chmod +x copy_backend_to_bastion.sh
./copy_backend_to_bastion.sh
```

**옵션 C: 수동으로 파일 복사**

SSM Session Manager에서 직접 파일을 생성하거나, 다른 방법으로 전송

### 6. Python 의존성 설치

```bash
cd ~/Backend
pip3 install --user -r requirements.txt
```

### 7. 데이터베이스 연결 테스트

```bash
mysql -h y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com \
      -u admin \
      -p'StrongPassword123!' \
      -e "SELECT 1;"
```

### 8. Backend 서버 실행

**포그라운드 실행 (테스트용):**
```bash
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

**백그라운드 실행:**
```bash
nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &

# 로그 확인
tail -f server.log

# 프로세스 확인
ps aux | grep uvicorn
```

### 9. 서버 테스트

다른 터미널에서 (로컬 또는 SSM Session Manager 새 세션):

```bash
# Health check
curl http://localhost:8000/api/v1/health
```

## 자동화 스크립트

자동으로 설정하려면:

```bash
cd /root/Terraform
python3 auto_setup_backend.py
```

이 스크립트는 1-4단계를 자동으로 실행합니다.

## 문제 해결

### Python 패키지 설치 오류
```bash
pip3 install --user --upgrade pip
pip3 install --user -r requirements.txt
```

### 데이터베이스 연결 실패
- 보안 그룹 규칙 확인
- RDS Proxy 엔드포인트 확인
- 네트워크 연결 테스트

### 서버가 시작되지 않음
```bash
# 포트 확인
netstat -tlnp | grep 8000

# 로그 확인
tail -f server.log
```

## 다음 단계

1. ✅ SSM Session Manager 접속
2. ✅ 필요한 도구 설치
3. ✅ 환경 변수 설정
4. ⏭️ Backend 코드 배포
5. ⏭️ 의존성 설치
6. ⏭️ 서버 실행

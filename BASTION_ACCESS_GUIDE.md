# Bastion 호스트 접속 및 Backend 실행 가이드

## ✅ 설정 완료 사항

- ✅ Bastion 보안 그룹 규칙 추가 완료
- ✅ RDS Proxy 보안 그룹에 Bastion 인바운드 규칙 추가 완료 (포트 3306)

## 📍 Bastion Public IP

- **KOR (Seoul)**: `35.92.218.177`
- **USA (Oregon)**: `43.202.0.201`

## 🔑 SSH 키 정보

- **KOR**: `KeyPair-Seoul`
- **USA**: `KeyPair-Oregon`

## 1. Bastion 호스트 접속

### KOR (Seoul) Bastion 접속

**⚠️ SSH 키 접속이 실패하는 경우, EC2 Instance Connect를 사용하세요 (권장)**

#### 방법 1: EC2 Instance Connect (키 불필요) ⭐

1. AWS 콘솔 → EC2 → Instances
2. IP 주소로 검색: `35.92.218.177`
3. 인스턴스 선택 → "Connect" → "EC2 Instance Connect"
4. "Connect" 버튼 클릭

#### 방법 2: SSH 키 사용

```bash
# SSH 키 파일 위치: /root/KeyPair-Seoul.pem
# 키 파일 권한 확인
chmod 400 /root/KeyPair-Seoul.pem

# 접속 시도
ssh -i /root/KeyPair-Seoul.pem ec2-user@35.92.218.177

# 접속 실패 시 디버그 모드
ssh -vvv -i /root/KeyPair-Seoul.pem ec2-user@35.92.218.177

# 또는 접속 스크립트 사용
cd /root/Terraform
chmod +x connect_bastion.sh
./connect_bastion.sh
```

**SSH 접속 문제 해결**: `/root/Terraform/SSH_TROUBLESHOOTING.md` 참고

### USA (Oregon) Bastion 접속

```bash
# SSH 키 파일이 있는 경우
ssh -i /root/KeyPair-Oregon.pem ec2-user@43.202.0.201

# 키 파일이 없는 경우: EC2 Instance Connect 또는 SSM Session Manager 사용
```

**참고**: USA Bastion 키 파일이 없는 경우, EC2 Instance Connect를 사용하거나 SSM Session Manager를 설정해야 합니다.

## 2. Bastion에서 Backend 설정

### 2.1 필요한 도구 설치

```bash
# 시스템 업데이트
sudo yum update -y

# Python 3 및 pip 설치
sudo yum install -y python3 python3-pip git

# MySQL 클라이언트 (연결 테스트용)
sudo yum install -y mysql
```

### 2.2 Backend 코드 배포

**옵션 1: SCP로 로컬에서 전송**

로컬 머신에서:
```bash
# Backend 디렉토리를 Bastion으로 전송
scp -i ~/.ssh/KeyPair-Seoul.pem -r /root/Backend ec2-user@35.92.218.177:~/Backend
```

**옵션 2: Git에서 클론**

Bastion에서:
```bash
git clone <your-backend-repo-url>
cd Backend
```

### 2.3 Python 의존성 설치

```bash
cd ~/Backend
pip3 install --user -r requirements.txt
```

## 3. 환경 변수 설정

Bastion에서 `.env` 파일 생성:

```bash
cd ~/Backend
cat > .env <<EOF
# Database (RDS Proxy 엔드포인트 사용)
DB_HOST=y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com
DB_PORT=3306
DB_USER=admin
DB_PASSWORD=StrongPassword123!
DB_NAME=your_database_name

# Database URL (SQLAlchemy 형식)
DATABASE_URL=mysql+pymysql://admin:StrongPassword123!@y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com:3306/your_database_name

# Keycloak (EKS 내부 서비스 또는 외부 URL)
KEYCLOAK_URL=http://keycloak-service:8080
KEYCLOAK_REALM=your-realm
KEYCLOAK_CLIENT_ID=backend-client

# Meilisearch (EKS 내부 서비스 또는 외부 URL)
MEILISEARCH_URL=http://meilisearch-service:7700
MEILISEARCH_API_KEY=masterKey123

# 기타
DEBUG=false
ENVIRONMENT=production
EOF
```

## 4. 데이터베이스 연결 테스트

```bash
# MySQL 클라이언트로 RDS Proxy 연결 테스트
mysql -h y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com \
      -u admin \
      -p'StrongPassword123!' \
      -e "SELECT 1;"
```

## 5. Backend 서버 실행

### 5.1 포그라운드 실행 (테스트용)

```bash
cd ~/Backend
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

### 5.2 백그라운드 실행 (프로덕션)

```bash
cd ~/Backend
nohup python3 -m uvicorn main:app --host 0.0.0.0 --port 8000 > server.log 2>&1 &

# 프로세스 확인
ps aux | grep uvicorn

# 로그 확인
tail -f server.log
```

### 5.3 systemd 서비스로 실행 (권장)

```bash
# 서비스 파일 생성
sudo tee /etc/systemd/system/backend.service > /dev/null <<EOF
[Unit]
Description=Backend API Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/home/ec2-user/Backend
Environment="PATH=/usr/bin:/usr/local/bin"
ExecStart=/usr/bin/python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 서비스 시작
sudo systemctl daemon-reload
sudo systemctl enable backend
sudo systemctl start backend

# 상태 확인
sudo systemctl status backend

# 로그 확인
sudo journalctl -u backend -f
```

## 6. 연결 테스트

### 6.1 Health Check

```bash
# Bastion에서
curl http://localhost:8000/api/v1/health

# 로컬에서 (Bastion의 Public IP로 접근 불가 - 보안 그룹에서 포트 8000이 열려있지 않음)
# SSH 터널링 필요:
ssh -i ~/.ssh/KeyPair-Seoul.pem -L 8000:localhost:8000 ec2-user@35.92.218.177
# 그 다음 로컬에서:
curl http://localhost:8000/api/v1/health
```

### 6.2 SSH 터널링으로 로컬에서 접근

```bash
# 로컬 머신에서 SSH 터널 생성
ssh -i ~/.ssh/KeyPair-Seoul.pem -L 8000:localhost:8000 ec2-user@35.92.218.177

# 다른 터미널에서
curl http://localhost:8000/api/v1/health
```

## 7. 네트워크 흐름

```
로컬 머신
  ↓ (SSH 터널)
Bastion (Public Subnet) - 35.92.218.177
  ↓ (포트 3306, 보안 그룹 규칙 적용됨)
RDS Proxy (Private Subnet - DB Layer)
  ↓
Aurora MySQL (Private Subnet - DB Layer)
```

## 8. 문제 해결

### 8.1 DB 연결 실패

```bash
# 보안 그룹 규칙 확인
aws ec2 describe-security-groups \
  --group-ids sg-07ceb1baf3095a6ef \
  --region ap-northeast-2 \
  --query 'SecurityGroups[0].IpPermissions'

# RDS Proxy 상태 확인
aws rds describe-db-proxies \
  --db-proxy-name y2om-formation-lap-kor-rds-proxy \
  --region ap-northeast-2

# 네트워크 연결 테스트
telnet y2om-formation-lap-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com 3306
```

### 8.2 포트 8000 접근 불가

- Bastion 보안 그룹에서 포트 8000 인바운드 규칙이 없습니다
- SSH 터널링을 사용하거나, 보안 그룹에 포트 8000 규칙을 추가해야 합니다

### 8.3 Keycloak/Meilisearch 연결 실패

- EKS 클러스터 내부 서비스인 경우 VPC 내부 DNS를 사용해야 합니다
- 또는 Docker Compose로 로컬에 실행할 수 있습니다

## 9. 보안 고려사항

1. **SSH 키 관리**: SSH 키 파일은 안전하게 보관하세요
2. **환경 변수**: `.env` 파일에 민감한 정보가 포함되어 있으므로 권한을 제한하세요:
   ```bash
   chmod 600 .env
   ```
3. **방화벽**: Bastion 보안 그룹은 관리자 IP(`175.192.170.212/32`)에서만 SSH 접속을 허용합니다

## 10. 다음 단계

1. ✅ Bastion 접속 완료
2. ✅ Backend 코드 배포
3. ✅ 환경 변수 설정
4. ✅ 서버 실행
5. ⏭️ 연결 테스트 및 모니터링

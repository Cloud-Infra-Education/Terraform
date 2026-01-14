# Backend 코드 전송 - 수동 실행 가이드 (GitHub 불필요)

## 방법 1: S3를 통한 전송 (권장) ⭐

터미널에서 다음 명령어를 순서대로 실행:

```bash
# 1. Backend 코드 압축
cd /root
tar -czf /tmp/backend.tar.gz \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.git' \
  --exclude='test.db' \
  --exclude='.env' \
  Backend/

# 2. S3에 업로드
aws s3 cp /tmp/backend.tar.gz \
  s3://y2om-my-origin-bucket-123456/backup/backend.tar.gz \
  --region ap-northeast-2

# 3. Bastion에서 다운로드 및 압축 해제
aws ssm send-command \
  --instance-ids i-0088889a043f54312 \
  --region ap-northeast-2 \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=[
    "cd ~/Backend",
    "aws s3 cp s3://y2om-my-origin-bucket-123456/backup/backend.tar.gz /tmp/backend.tar.gz",
    "tar -xzf /tmp/backend.tar.gz --strip-components=1",
    "rm /tmp/backend.tar.gz",
    "ls -la | head -20"
  ]' \
  --output text \
  --query 'Command.CommandId'
```

**60초 후 결과 확인:**
```bash
# Command ID를 위에서 받은 값으로 교체
aws ssm get-command-invocation \
  --command-id <COMMAND_ID> \
  --instance-id i-0088889a043f54312 \
  --region ap-northeast-2 \
  --query '[Status,StandardOutputContent]' \
  --output table
```

## 방법 2: Python 스크립트 실행 (수정됨)

```bash
cd /root/Terraform
python3 transfer_via_s3.py
```

## 방법 3: SSM Session Manager에서 직접 파일 생성

SSM Session Manager로 접속한 후, 주요 파일들을 직접 생성:

```bash
# SSM 접속
aws ssm start-session --target i-0088889a043f54312 --region ap-northeast-2

# 접속 후
cd ~/Backend

# requirements.txt 생성
cat > requirements.txt <<'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
pydantic==2.5.0
pydantic-settings==2.1.0
email-validator==2.1.0
python-jose[cryptography]==3.3.0
sqlalchemy==2.0.23
pymysql==1.1.0
cryptography==41.0.7
alembic==1.12.1
passlib[bcrypt]==1.7.4
bcrypt==4.0.1
meilisearch==0.32.0
httpx==0.25.2
python-dotenv==1.0.0
EOF

# 그 다음 로컬에서 파일 내용을 복사하여 생성
```

## 다음 단계

코드 전송 완료 후:

```bash
# SSM Session Manager로 접속
aws ssm start-session --target i-0088889a043f54312 --region ap-northeast-2

# 접속 후
cd ~/Backend
ls -la  # 파일 확인
pip3 install --user -r requirements.txt
python3 -m uvicorn main:app --host 0.0.0.0 --port 8000
```

## 문제 해결

### S3 업로드 실패
- S3 버킷 이름 확인: `y2om-my-origin-bucket-123456`
- 권한 확인: `aws s3 ls s3://y2om-my-origin-bucket-123456/`

### SSM 명령어 실행 실패
- 인스턴스 상태 확인: `aws ec2 describe-instances --instance-ids i-0088889a043f54312 --region ap-northeast-2 --query 'Reservations[0].Instances[0].State.Name'`
- SSM Agent 상태 확인: `aws ssm describe-instance-information --filters "Key=InstanceIds,Values=i-0088889a043f54312" --region ap-northeast-2`

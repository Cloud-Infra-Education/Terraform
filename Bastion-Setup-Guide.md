# Bastion을 통한 RDS Proxy 연결 설정 가이드

## 목표
Lambda 함수가 Public Subnet의 Bastion을 거쳐서 RDS Proxy로 연결되도록 설정

## 현재 구조
```
Lambda (Private Subnet)
  ↓
Bastion (Public Subnet) - HAProxy 프록시
  ↓
RDS Proxy (Private Subnet)
  ↓
Aurora MySQL (Private Subnet)
```

## 설정 단계

### 1. Terraform Apply

#### 1-1. 01-infra 적용 (Bastion output 추가)
```bash
cd /root/Terraform/01-infra
terraform apply
```

확인:
```bash
terraform output kor_bastion_private_ip
```

#### 1-2. 03-database 적용 (Lambda SG ID 확인)
```bash
cd /root/Terraform/03-database
terraform apply
```

Lambda SG ID 확인:
```bash
terraform output lambda_sg_id
# 예: sg-080b3d0a25eb4e41f
```

### 2. Bastion Security Group 업데이트

Lambda SG에서 Bastion으로의 접근 규칙 추가:

```bash
cd /root/Terraform/scripts
./update-bastion-sg.sh <lambda_sg_id>
```

예시:
```bash
./update-bastion-sg.sh sg-080b3d0a25eb4e41f
```

### 3. Bastion에 HAProxy 설치

Bastion에 프록시 서버 설치:

```bash
cd /root/Terraform/scripts

# Bastion IP와 RDS Proxy Endpoint 확인
BASTION_IP="10.33.1.74"  # terraform output에서 확인
RDS_PROXY="formation-lap-yuh-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com"

# SSH 키 설정 (필요시)
export SSH_KEY=~/.ssh/your-key.pem
export SSH_USER=ec2-user

# HAProxy 설치
./setup-bastion-proxy.sh $BASTION_IP $RDS_PROXY
```

### 4. Lambda 함수 재배포

새 환경변수가 반영되도록 Lambda 함수 재배포:

```bash
# Lambda Docker 이미지 재빌드 및 푸시
cd /root/Backend/lambda/video-processor
# ... Docker 이미지 빌드 및 ECR 푸시 ...

# Lambda 함수 업데이트 (또는 Terraform apply)
cd /root/Terraform/03-database
terraform apply
```

### 5. 연결 테스트

#### 5-1. S3에 테스트 영상 업로드
```bash
aws s3 cp test-video.mp4 s3://yuh-team-formation-lap-origin-s3/videos/
```

#### 5-2. CloudWatch 로그 확인
```bash
aws logs tail /aws/lambda/formation-lap-video-processor --follow --region ap-northeast-2
```

확인 사항:
- `Bastion을 통한 연결 모드` 로그 확인
- `DB 연결 성공` 메시지 확인
- `contents ... 등록 완료` 메시지 확인

## 확인된 정보

- **Bastion Private IP**: `10.33.1.74`
- **Bastion Public IP**: `13.125.60.221`
- **RDS Proxy Endpoint**: `formation-lap-yuh-kor-rds-proxy.proxy-c902seqsaaps.ap-northeast-2.rds.amazonaws.com`
- **Lambda SG ID**: `sg-080b3d0a25eb4e41f` (terraform output에서 확인)

## 문제 해결

### Bastion 연결 실패
- Security Group 규칙 확인
- HAProxy 서비스 상태 확인: `sudo systemctl status haproxy`

### Lambda에서 Bastion 연결 실패
- Lambda 환경변수 확인: `BASTION_HOST`, `PROXY_ENDPOINT`
- CloudWatch 로그에서 에러 메시지 확인

### RDS Proxy 연결 실패
- HAProxy 설정 파일 확인: `/etc/haproxy/haproxy.cfg`
- RDS Proxy 엔드포인트 확인

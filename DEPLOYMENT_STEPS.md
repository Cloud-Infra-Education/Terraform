# Lambda 함수 배포 가이드

## 사전 준비 사항

### 1. Terraform 스택 실행 순서
다음 순서로 실행해야 합니다:

```bash
# 1. 인프라 생성 (VPC, S3)
cd 01-infra
terraform init
terraform apply

# 2. Kubernetes 및 ECR 생성
cd ../02-kubernetes
terraform init
terraform apply

# 3. Database 생성 (RDS Proxy 포함)
cd ../03-database
terraform init
terraform apply
```

### 2. Lambda Docker 이미지 빌드 및 푸시

#### Video Processor Lambda
```bash
cd /root/Backend/lambda/video-processor

# Docker 이미지 빌드
docker build -t video-processor:latest .

# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin <ECR_URL>

# 이미지 태그 및 푸시
# ECR URL은 02-kubernetes terraform apply 후 outputs에서 확인
ECR_URL=$(cd ../../Terraform/02-kubernetes && terraform output -raw video_processor_repo_url)
docker tag video-processor:latest ${ECR_URL}:v1
docker push ${ECR_URL}:v1
```

#### Alert Service Lambda
```bash
cd /root/Backend/lambda/alert-service

# Docker 이미지 빌드
docker build -t alert-service:latest .

# ECR 로그인
aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin <ECR_URL>

# 이미지 태그 및 푸시
ECR_URL=$(cd ../../Terraform/02-kubernetes && terraform output -raw alert_service_repo_url)
docker tag alert-service:latest ${ECR_URL}:v1
docker push ${ECR_URL}:v1
```

### 3. 01-infra 재실행 (Lambda 함수 생성)

Database와 ECR이 생성된 후, 01-infra를 다시 실행하여 Lambda 함수를 생성합니다:

```bash
cd /root/Terraform/01-infra

# terraform.tfvars 파일에 다음 변수 추가 (필요한 경우)
# db_username = "your_db_username"
# db_password = "your_db_password"
# our_team = "your_team_name"

terraform apply
```

## 테스트 방법

### 1. S3에 테스트 영상 업로드
```bash
# S3 버킷 이름 확인
cd /root/Terraform/01-infra
BUCKET_NAME=$(terraform output -raw origin_bucket_name)

# 테스트 영상 업로드 (videos/ 폴더에 .mp4 파일)
aws s3 cp test-video.mp4 s3://${BUCKET_NAME}/videos/test_$(date +%s).mp4
```

### 2. Lambda 함수 로그 확인
```bash
# CloudWatch Logs에서 확인
aws logs tail /aws/lambda/<your-team>-video-processor --follow --region ap-northeast-2
```

### 3. 데이터베이스 확인
```bash
# RDS Proxy 엔드포인트 확인
cd /root/Terraform/03-database
PROXY_ENDPOINT=$(terraform output -raw proxy_endpoint)

# MySQL 클라이언트로 연결 테스트
mysql -h ${PROXY_ENDPOINT} -u <db_username> -p ott_db

# 테이블 확인
SHOW TABLES;
SELECT * FROM contents;
SELECT * FROM video_assets;
```

## 문제 해결

### Lambda 함수가 실행되지 않는 경우
1. VPC 설정 확인: Lambda가 올바른 서브넷과 Security Group에 배치되었는지 확인
2. IAM 역할 확인: Lambda 실행 역할에 필요한 권한이 있는지 확인
3. ECR 이미지 확인: 이미지가 올바르게 푸시되었는지 확인

### RDS Proxy 연결 실패
1. Security Group 규칙 확인: Lambda Security Group에서 RDS Proxy로의 인바운드 규칙 확인
2. 네트워크 경로 확인: Lambda가 있는 서브넷에서 RDS Proxy로의 네트워크 경로 확인
3. Secrets Manager 확인: DB 자격 증명이 올바르게 설정되었는지 확인

### S3 접근 실패
1. VPC Endpoint 확인: S3 Gateway Endpoint가 올바르게 생성되었는지 확인
2. Route Table 확인: Private 서브넷의 Route Table에 S3 Gateway Endpoint 경로가 추가되었는지 확인

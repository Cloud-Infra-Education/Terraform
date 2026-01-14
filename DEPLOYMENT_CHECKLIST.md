# Video Processor Lambda 배포 체크리스트

## Terraform Apply 전 확인 사항

### 1. ECR에 Docker 이미지가 푸시되었는지 확인

```bash
# ECR 리포지토리 확인
aws ecr describe-repositories --repository-names yuh-video-processor

# 이미지 태그 확인 (v1 태그가 있어야 함)
aws ecr describe-images --repository-name yuh-video-processor --image-ids imageTag=v1
```

**이미지가 없다면:**
```bash
cd Backend/lambda/video-processor

# Docker 이미지 빌드 및 푸시
# (ECR 로그인, 빌드, 태깅, 푸시 스크립트 실행)
```

### 2. Terraform 변수 확인

`terraform.tfvars` 파일에서 다음 변수들이 올바르게 설정되었는지 확인:

- `our_team`: 팀 이름 (예: "yuh")
- `origin_bucket_name`: S3 버킷 이름
- `db_username`: DB 사용자명
- `db_password`: DB 비밀번호
- `db_name`: DB 이름 (기본값: ott_db)

### 3. 의존성 모듈 확인

다음 모듈들이 먼저 배포되어 있어야 함:

- `module.network`: VPC, 서브넷 생성
- `module.database`: RDS Proxy 생성 (Lambda가 연결할 DB)
- `module.ecr`: ECR 리포지토리 생성

## Terraform Apply

```bash
cd Terraform

# 계획 확인
terraform plan

# 적용
terraform apply
```

## 배포 후 확인 사항

### 1. Lambda 함수 확인

```bash
# Lambda 함수가 생성되었는지 확인
aws lambda get-function --function-name {your-team}-video-processor

# 환경 변수 확인
aws lambda get-function-configuration \
  --function-name {your-team}-video-processor \
  --query 'Environment.Variables'
```

**확인할 환경 변수:**
- `DB_HOST`: RDS Proxy 엔드포인트여야 함
- `DB_USER`: DB 사용자명
- `DB_PASSWORD`: DB 비밀번호
- `DB_NAME`: DB 이름

### 2. S3 버킷 알림 확인

```bash
# S3 버킷 알림 설정 확인
aws s3api get-bucket-notification-configuration \
  --bucket {your-bucket-name}
```

**확인 사항:**
- Lambda 함수 ARN이 올바른지
- `filter_prefix`가 `videos/`인지
- `filter_suffix`가 `.mp4`인지

### 3. IAM 역할 및 권한 확인

```bash
# Lambda 실행 역할 확인
aws iam get-role --role-name {your-team}-video-processor-role

# 정책 확인
aws iam list-role-policies --role-name {your-team}-video-processor-role
aws iam list-attached-role-policies --role-name {your-team}-video-processor-role
```

### 4. VPC 설정 확인

```bash
# Lambda 함수의 VPC 설정 확인
aws lambda get-function-configuration \
  --function-name {your-team}-video-processor \
  --query 'VpcConfig'
```

**확인 사항:**
- 서브넷 ID가 올바른지
- Security Group ID가 올바른지
- Security Group이 RDS Proxy에 접근할 수 있는지

## 테스트 방법

### 1. 테스트 영상 업로드

```bash
# 작은 테스트 영상 파일 준비 (또는 기존 영상 사용)
# 중요: videos/ 경로로 시작하고 .mp4 확장자 사용

aws s3 cp test-video.mp4 s3://{your-bucket}/videos/test_$(date +%Y%m%d%H%M%S).mp4
```

### 2. CloudWatch Logs 확인

```bash
# 로그 그룹 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/lambda" | grep video-processor

# 실시간 로그 확인
aws logs tail /aws/lambda/{your-team}-video-processor --follow
```

**예상 로그:**
```
환경 변수 확인 - DB_HOST: ..., DB_USER: ..., DB_NAME: ...
영상 처리 시작: videos/test_...
DB 연결 시도: ...
DB 연결 성공
파일명에서 content_id 추출: ...
추출된 메타데이터: ...
contents 테이블에 등록 완료 (content_id: ...)
video_assets 테이블에 등록 완료 (content_id: ...)
성공: videos/test_... 등록 완료
```

### 3. Lambda 실행 이력 확인

```bash
# 최근 실행 확인
aws lambda list-functions --query 'Functions[?contains(FunctionName, `video-processor`)]'

# 실행 통계 확인
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value={your-team}-video-processor \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

### 4. DB 확인

```sql
-- RDS Proxy를 통해 DB 접속
mysql -h {rds-proxy-endpoint} -u {db-user} -p

-- contents 테이블 확인
SELECT * FROM contents ORDER BY id DESC LIMIT 5;

-- video_assets 테이블 확인
SELECT * FROM video_assets ORDER BY id DESC LIMIT 5;
```

## 문제 해결

### Lambda가 트리거되지 않는 경우

1. **S3 버킷 알림 확인:**
```bash
aws s3api get-bucket-notification-configuration --bucket {your-bucket}
```

2. **파일 경로 확인:**
   - `videos/`로 시작하는지
   - `.mp4` 확장자인지

3. **Lambda 권한 확인:**
```bash
aws lambda get-policy --function-name {your-team}-video-processor
```

### DB 연결 실패하는 경우

1. **환경 변수 확인:**
```bash
aws lambda get-function-configuration \
  --function-name {your-team}-video-processor \
  --query 'Environment.Variables'
```

2. **RDS Proxy 엔드포인트 확인:**
```bash
# Terraform outputs에서 확인
terraform output
```

3. **Security Group 확인:**
   - Lambda의 Security Group이 RDS Proxy의 Security Group에 접근할 수 있는지
   - 포트 3306이 열려있는지

### 에러는 없지만 DB에 저장 안되는 경우

1. **CloudWatch Logs에서 전체 로그 확인**
2. **DB 커밋 확인** (로그에 "video_assets 테이블에 등록 완료"가 있는지)
3. **트랜잭션 에러 확인**

## 성공 확인

다음이 모두 확인되면 성공:

- ✅ CloudWatch Logs에 "성공: ... 등록 완료" 메시지
- ✅ `contents` 테이블에 새 레코드 추가됨
- ✅ `video_assets` 테이블에 새 레코드 추가됨
- ✅ S3에 썸네일이 생성됨 (`thumbnails/` 경로)

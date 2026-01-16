# Video Processing Lambda 구현 문서

## 개요
S3에 영상 파일이 업로드되면 자동으로 메타데이터를 추출하고 Backend API에 저장하는 Lambda 함수를 구현했습니다.

## 구현 내용

### 1. Lambda 함수 구성

#### 1.1 주요 리소스
- **Lambda Function**: `yuh-formation-lap-video-processor`
- **Runtime**: Python 3.11
- **Timeout**: 300초 (5분)
- **Memory**: 1024 MB
- **Handler**: `app.lambda_handler`

#### 1.2 배포 패키지 빌드
- **스크립트**: `build-lambda.sh`
- **위치**: `/root/Terraform/modules/lambda/build-lambda.sh`
- **기능**:
  - Lambda 함수 소스 코드 복사
  - Python 의존성 설치 (`requirements.txt`)
  - 불필요한 파일 제거 (`__pycache__`, `.pyc`, `.dist-info` 등)
  - ZIP 파일 생성 (루트에 모든 파일 포함)

#### 1.3 FFmpeg Layer
- **스크립트**: `build-ffmpeg-layer.sh`
- **기능**: FFmpeg/FFprobe 바이너리를 Lambda Layer로 패키징
- **배포 방식**: S3에 업로드 후 Layer로 참조
- **경로**: `s3://{bucket}/lambda-layers/ffmpeg-layer.zip`
- **용도**: 비디오 duration 추출

### 2. 인프라 구성

#### 2.1 VPC 설정
- **서브넷**: Private Subnet 사용
- **보안 그룹**: Lambda 전용 보안 그룹
- **용도**: RDS Proxy 접근을 위한 VPC 내부 배치

#### 2.2 IAM 역할 및 권한
- **역할**: `yuh-formation-lap-video-processor-role`
- **권한**:
  - `AWSLambdaBasicExecutionRole`: CloudWatch Logs
  - `AWSLambdaVPCAccessExecutionRole`: VPC 접근
  - S3 읽기/쓰기 권한 (원본 버킷 읽기, 썸네일 업로드)
  - RDS Data API 권한 (선택사항)

#### 2.3 S3 이벤트 트리거
- **트리거 조건**:
  - Prefix: `videos/`
  - Suffix: `.mp4`
  - Events: `s3:ObjectCreated:Put`, `s3:ObjectCreated:CompleteMultipartUpload`
- **Lambda 권한**: S3가 Lambda 함수를 호출할 수 있도록 권한 부여

### 3. 환경 변수

| 변수명 | 설명 | 예시 |
|--------|------|------|
| `CATALOG_API_BASE` | Backend API 기본 URL | `https://api.matchacake.click` |
| `INTERNAL_TOKEN` | 내부 API 인증 토큰 | - |
| `S3_BUCKET` | S3 버킷 이름 | `yuh-team-formation-lap-origin-s3` |
| `S3_REGION` | S3 리전 | `ap-northeast-2` |
| `CLOUDFRONT_DOMAIN` | CloudFront 도메인 | `www.matchacake.click` |
| `TMDB_API_KEY` | TMDB API 키 | - |
| `DB_NAME` | 데이터베이스 이름 | `y2om_db` |
| `DB_USER` | 데이터베이스 사용자 | `admin` |
| `DB_PASSWORD` | 데이터베이스 비밀번호 | - |
| `DB_HOST` | 데이터베이스 호스트 | RDS Proxy 엔드포인트 |

### 4. Terraform 모듈 구조

```
modules/lambda/
├── video-processor.tf      # Lambda 함수 리소스 정의
├── iam.tf                  # IAM 역할 및 정책
├── security-group.tf      # 보안 그룹
├── variables.tf           # 변수 정의
├── outputs.tf             # 출력 값
├── build-lambda.sh        # Lambda 배포 패키지 빌드 스크립트
└── build-ffmpeg-layer.sh  # FFmpeg Layer 빌드 스크립트
```

### 5. 배포 프로세스

1. **Lambda 코드 빌드**
   ```bash
   ./build-lambda.sh
   # → lambda-function.zip 생성
   ```

2. **FFmpeg Layer 빌드**
   ```bash
   ./build-ffmpeg-layer.sh
   # → ffmpeg-layer.zip 생성 및 S3 업로드
   ```

3. **Terraform Apply**
   ```bash
   cd /root/Terraform/03-database
   terraform apply
   ```

### 6. 사용 기술

- **AWS Lambda**: 서버리스 함수 실행
- **AWS S3**: 영상 파일 저장 및 이벤트 트리거
- **AWS CloudFront**: CDN을 통한 영상 배포
- **FFmpeg/FFprobe**: 비디오 메타데이터 추출
- **Terraform**: Infrastructure as Code
- **Python 3.11**: Lambda 함수 런타임

### 7. 주요 파일

- `video-processor.tf`: Lambda 함수 및 관련 리소스 정의
- `build-lambda.sh`: Lambda 배포 패키지 빌드
- `build-ffmpeg-layer.sh`: FFmpeg Layer 빌드
- `iam.tf`: IAM 역할 및 정책 정의
- `security-group.tf`: 보안 그룹 규칙

### 8. 트러블슈팅

#### 8.1 ZIP 파일 구조 문제
- **문제**: `app.py`가 루트에 없어서 `No module named 'app'` 오류
- **해결**: `build-lambda.sh`에서 ZIP 생성 시 루트에 모든 파일이 오도록 수정

#### 8.2 FFmpeg Layer 크기 문제
- **문제**: Layer ZIP 파일이 57MB로 직접 업로드 불가
- **해결**: S3에 업로드 후 Layer로 참조하도록 변경

#### 8.3 TMDB API 언어 문제
- **문제**: 한국어로 요청 시 `overview`가 비어있음
- **해결**: 한국어 실패 시 영어로 재시도하는 로직 추가

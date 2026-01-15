# 07-domain-cf: 도메인 및 애플리케이션 배포

## 개요

도메인 설정, CloudFront 구성, Backend API 및 Meilisearch 배포를 담당하는 핵심 단계입니다.

## 구성 요소

### 1. CloudFront
- S3 Origin (정적 웹사이트)
- Origin Access Control (OAC) 설정
- SSL 인증서 연동

### 2. Route53 레코드
- `www.exampleott.click` → CloudFront Distribution
- `api.exampleott.click` → ALB (서울/오레곤)

### 3. ALB Ingress
- Kubernetes Ingress 리소스
- `/api/v1/*` → Backend API Service
- `/docs` → Backend API Service
- SSL 인증서 자동 적용

### 4. Backend API 배포
- Kubernetes Deployment
- ECR 이미지 사용
- 환경 변수: Keycloak, Meilisearch, Database 연결 정보
- S3 접근 권한 (IRSA)

### 5. Meilisearch 배포
- Kubernetes Deployment
- `getmeili/meilisearch:latest` 이미지
- 포트: 7700

## 배포 위치

**AWS에서 별도로 실행되는 리소스:**
- CloudFront Distribution
- Route53 DNS 레코드
- ALB (Application Load Balancer)

**EKS에 배포되는 리소스:**
- Backend API (Pod)
- Meilisearch (Pod)
- Kubernetes Ingress 리소스
- Kubernetes Service 리소스

## 출력 (Remote State)

다음 스택에서 참조합니다:
- CloudFront Distribution ID
- ALB DNS 이름

## 배포 방법

```bash
cd 07-domain-cf
terraform init
terraform plan
terraform apply
```

## 의존성

- `01-infra` (S3, VPC)
- `02-kubernetes` (EKS 클러스터)
- `03-database` (RDS Proxy 엔드포인트)
- `04-addons` (ALB Controller)
- `06-certificate` (ACM 인증서)

## 주요 기능

### Backend API S3 접근
- IRSA (IAM Roles for Service Accounts)를 통한 S3 읽기 권한
- S3 파일 목록 조회 API: `/api/v1/contents/{content_id}/video-assets/s3/list`
- CloudFront URL 생성 API: `/api/v1/contents/{content_id}/video-assets/s3/url/{s3_key}`

### 영상 파일 제공
- S3 버킷에 영상 파일 저장
- CloudFront를 통한 CDN 제공: `https://www.exampleott.click/{파일경로}`

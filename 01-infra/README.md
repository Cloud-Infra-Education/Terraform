# 01-infra: 기본 인프라

## 개요

네트워크 기반 구축 및 스토리지 준비를 담당하는 최초 실행 단계입니다.

## 구성 요소

### 1. VPC (Virtual Private Cloud)
- **서울 리전**: `kor_vpc_id`
- **오레곤 리전**: `usa_vpc_id`
- 각 리전별 Public/Private 서브넷 구성
- Transit Gateway를 통한 리전 간 연결

### 2. S3 버킷
- CloudFront Origin용 버킷 생성
- 정적 웹사이트 호스팅용
- 영상 파일 저장소

## 배포 위치

**AWS에서 별도로 실행되는 리소스:**
- VPC, 서브넷, Transit Gateway
- S3 버킷

**EKS에 배포되는 리소스:** 없음

## 출력 (Remote State)

다음 스택에서 참조합니다:
- `kor_vpc_id`, `usa_vpc_id`
- `kor_private_eks_subnet_ids`, `usa_private_eks_subnet_ids`
- `kor_private_db_subnet_ids`, `usa_private_db_subnet_ids`
- `origin_bucket_name`

## 배포 방법

```bash
cd 01-infra
terraform init
terraform plan
terraform apply
```

## 의존성

없음 (최초 실행 단계)

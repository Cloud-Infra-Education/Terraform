# 09-domain-access-logs: 도메인 접근 로그

## 개요

DNS 쿼리 로그 수집 및 분석을 담당하는 단계입니다.

## 구성 요소

### 1. Route53 Query Logging
- CloudWatch Logs로 로그 전송

### 2. Lambda 함수
- CloudWatch Logs 트리거
- DNS 쿼리 파싱 및 OpenSearch 인덱싱

### 3. OpenSearch Domain
- DNS 쿼리 데이터 저장
- 대시보드를 통한 시각화

## 배포 위치

**AWS에서 별도로 실행되는 리소스:**
- CloudWatch Logs
- Lambda 함수
- OpenSearch Domain

**EKS에 배포되는 리소스:** 없음

## 배포 방법

```bash
cd 09-domain-access-logs
terraform init
terraform plan
terraform apply
```

## 의존성

- `01-infra` (Route53 Hosted Zone)

## 참고

DNS 로그 수집은 선택사항이며, 분석이 필요한 경우에만 배포합니다.

# 06-certificate: SSL 인증서

## 개요

HTTPS 통신을 위한 SSL/TLS 인증서 발급을 담당하는 단계입니다.

## 구성 요소

### 1. ACM (AWS Certificate Manager)
- `api.exampleott.click` (서울 리전)
- `api.exampleott.click` (오레곤 리전)
- `www.exampleott.click` (CloudFront용, us-east-1)

### 2. Route53 DNS 검증
- DNS 레코드를 통한 인증서 검증
- 자동 검증 완료 대기

## 배포 위치

**AWS에서 별도로 실행되는 리소스:**
- ACM 인증서
- Route53 DNS 레코드

**EKS에 배포되는 리소스:** 없음

## 출력 (Remote State)

다음 스택에서 참조합니다:
- `acm_arn_api_seoul`
- `acm_arn_api_oregon`
- `acm_arn_www`
- `dvo_api_seoul`, `dvo_api_oregon`, `dvo_www` (DNS 검증 정보)

## 배포 방법

```bash
cd 06-certificate
terraform init
terraform plan
terraform apply
```

## 의존성

- `01-infra` (Route53 Hosted Zone)
- 도메인 소유권 확인 필요

## 주의사항

인증서 검증은 DNS 레코드 생성 후 자동으로 완료되지만, 완료까지 몇 분이 소요될 수 있습니다.

# 08-domain-ga: Global Accelerator

## 개요

글로벌 트래픽 최적화 및 고가용성을 담당하는 단계입니다.

## 구성 요소

### 1. AWS Global Accelerator
- 서울 및 오레곤 ALB를 엔드포인트로 등록
- Anycast IP 제공
- 자동 장애 조치

## 배포 위치

**AWS에서 별도로 실행되는 리소스:**
- Global Accelerator

**EKS에 배포되는 리소스:** 없음

## 배포 방법

```bash
cd 08-domain-ga
terraform init
terraform plan
terraform apply
```

## 의존성

- `07-domain-cf` (ALB 생성 필요)

## 참고

Global Accelerator는 선택사항이며, 단일 리전 배포 시 불필요할 수 있습니다.

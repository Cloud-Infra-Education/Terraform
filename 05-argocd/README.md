# 05-argocd: ArgoCD

## 개요

GitOps 기반 애플리케이션 배포 자동화를 담당하는 단계입니다.

## 구성 요소

### 1. ArgoCD Helm Chart
- 서울 및 오레곤 리전에 배포
- Git Repository 연동
- 자동 동기화 설정

### 2. ArgoCD Application
- Git Repository에서 애플리케이션 매니페스트 읽기
- Kubernetes 리소스 자동 배포

## 배포 위치

**AWS에서 별도로 실행되는 리소스:** 없음

**EKS에 배포되는 리소스:**
- ArgoCD Server (Pod)
- ArgoCD Application Controller (Pod)
- ArgoCD Repo Server (Pod)

## 배포 방법

```bash
cd 05-argocd
terraform init
terraform plan
terraform apply
```

## 의존성

- `02-kubernetes` (EKS 클러스터 필요)

## 참고

ArgoCD는 선택사항이며, 직접 `kubectl`로 배포할 수도 있습니다.

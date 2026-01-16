# 04-addons: Kubernetes Addons

## 개요

EKS 클러스터에 필수 애드온 설치를 담당하는 단계입니다.

## 구성 요소

### 1. AWS Load Balancer Controller
- ALB Ingress Controller
- IRSA를 통한 IAM 권한 부여
- ALB 자동 생성 및 관리

### 2. Cluster Autoscaler
- Helm Chart를 통한 배포
- IRSA 설정

## 배포 위치

**AWS에서 별도로 실행되는 리소스:**
- ALB (Application Load Balancer) - Ingress 리소스 생성 시 자동 생성

**EKS에 배포되는 리소스:**
- AWS Load Balancer Controller (Pod)
- Cluster Autoscaler (Pod)

## 배포 방법

```bash
cd 04-addons
terraform init
terraform plan
terraform apply
```

## 의존성

- `02-kubernetes` (EKS 클러스터 필요)

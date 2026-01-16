# 02-kubernetes: Kubernetes 클러스터

## 개요

컨테이너 오케스트레이션 환경 구축을 담당하는 단계입니다.

## 구성 요소

### 1. EKS (Elastic Kubernetes Service)
- **서울 리전**: `y2om-formation-lap-seoul`
- **오레곤 리전**: `y2om-formation-lap-oregon`
- 버전: Kubernetes 1.34
- Node Groups: t3.large (Seoul), t3.small (Oregon)

### 2. Cluster Autoscaler
- IRSA (IAM Roles for Service Accounts) 설정
- 자동 노드 스케일링

### 3. ECR (Elastic Container Registry)
- Docker 이미지 저장소
- 리전 간 복제 설정

## 배포 위치

**AWS에서 별도로 실행되는 리소스:**
- EKS 클러스터 자체 (관리형 서비스)
- ECR 레지스트리

**EKS에 배포되는 리소스:** 없음 (이 단계에서는 클러스터만 생성)

## 출력 (Remote State)

다음 스택에서 참조합니다:
- `seoul_cluster_name`, `oregon_cluster_name`
- `seoul_oidc_provider_arn`, `oregon_oidc_provider_arn`
- `seoul_eks_workers_sg_id`, `oregon_eks_workers_sg_id`

## 배포 방법

```bash
cd 02-kubernetes
terraform init
terraform plan
terraform apply
```

## 의존성

- `01-infra` (VPC, 서브넷 필요)

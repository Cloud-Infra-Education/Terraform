# 03-database: 데이터베이스

## 개요

애플리케이션 데이터 저장소 구축을 담당하는 단계입니다.

## 구성 요소

### 1. RDS Aurora MySQL
- Multi-AZ 배포
- 서울 리전에 Primary, 오레곤 리전에 Replica
- 자동 백업 및 스냅샷

### 2. RDS Proxy
- 연결 풀링
- Secrets Manager와 연동하여 자동 인증
- EKS 워커 노드에서 접근 가능

### 3. Secrets Manager
- DB 비밀번호 저장
- 자동 로테이션 설정

## 배포 위치

**AWS에서 별도로 실행되는 리소스:**
- RDS Aurora MySQL 클러스터
- RDS Proxy
- Secrets Manager

**EKS에 배포되는 리소스:** 없음

## 출력 (Remote State)

다음 스택에서 참조합니다:
- `kor_db_proxy_endpoint`
- `usa_db_proxy_endpoint`
- `db_cluster_endpoint`

## 배포 방법

```bash
cd 03-database
terraform init
terraform plan
terraform apply
```

## 의존성

- `01-infra` (VPC, 서브넷)
- `02-kubernetes` (EKS 워커 노드 Security Group)

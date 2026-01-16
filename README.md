# Terraform 인프라 프로젝트

## 목차
1. [프로젝트 개요](#프로젝트-개요)
2. [빠른 시작](#빠른-시작)
3. [인프라 구조](#인프라-구조)
4. [배포 가이드](#배포-가이드)
5. [테스트 가이드](#테스트-가이드)
6. [문서 참조](#문서-참조)

---

## 프로젝트 개요

이 프로젝트는 AWS 인프라를 Terraform으로 관리하는 멀티 리전(Multi-Region) 인프라스트럭처입니다.

### 주요 구성 요소
- **네트워크**: VPC, 서브넷, Transit Gateway (서울/오레곤)
- **컨테이너**: EKS 클러스터 (Kubernetes)
- **데이터베이스**: RDS Aurora MySQL, RDS Proxy
- **도메인**: Route53, ACM, CloudFront, ALB
- **애플리케이션**: Backend API, Keycloak, Meilisearch
- **모니터링**: Loki, Mimir, Tempo, Grafana

---

## 빠른 시작

### 전체 인프라 배포

```bash
cd /root/Terraform
./scripts/terraform-apply.sh
```

이 스크립트는 다음 순서로 인프라를 배포합니다:
1. `01-infra`: 네트워크, S3
2. `02-kubernetes`: EKS 클러스터
3. `03-database`: RDS, RDS Proxy
4. `04-addons`: ALB Controller
5. `05-argocd`: ArgoCD
6. `06-certificate`: ACM 인증서
7. `07-domain-cf`: CloudFront, 도메인, Backend API, Meilisearch
8. `08-domain-ga`: Global Accelerator
9. `09-domain-access-logs`: DNS 로그 수집
10. `10-app-monitoring`: 모니터링 스택

⚠️ **주의**: 전체 인프라 배포는 30분~1시간이 소요될 수 있습니다.

### 개별 스택 배포

특정 스택만 배포하려면:

```bash
cd /root/Terraform/07-domain-cf
terraform init
terraform apply -var-file=../terraform.tfvars -auto-approve
```

---

## 인프라 구조

### 디렉토리 구조

```
Terraform/
├── 01-infra/              # 기본 인프라 (VPC, Network, S3)
├── 02-kubernetes/         # EKS 클러스터
├── 03-database/           # RDS, RDS Proxy
├── 04-addons/             # Addons (ALB Controller)
├── 05-argocd/             # ArgoCD
├── 06-certificate/        # ACM 인증서
├── 07-domain-cf/          # CloudFront, 도메인, Backend API, Meilisearch
├── 08-domain-ga/          # Global Accelerator
├── 09-domain-access-logs/ # DNS 로그 수집
├── 10-app-monitoring/     # 모니터링 (Loki, Mimir, Tempo, Grafana)
├── modules/               # 재사용 가능한 모듈
│   ├── network/
│   ├── eks/
│   ├── database/
│   ├── domain/
│   └── ...
└── scripts/               # 배포 스크립트
    ├── terraform-apply.sh
    └── terraform-destroy.sh
```

### 인프라 흐름

자세한 인프라 흐름은 [인프라_전체_흐름.md](./인프라_전체_흐름.md)를 참고하세요.

**간단한 흐름:**
```
1. 네트워크 구축 (VPC, 서브넷)
   ↓
2. EKS 클러스터 생성
   ↓
3. 데이터베이스 구축 (RDS, RDS Proxy)
   ↓
4. Kubernetes Addons 설치
   ↓
5. 도메인 및 인증서 설정
   ↓
6. 애플리케이션 배포 (Backend API, Meilisearch)
```

---

## 배포 가이드

### Backend API 배포

Backend API는 `07-domain-cf` 스택에서 자동으로 배포됩니다.

#### 필수 변수 설정

`terraform.tfvars` 파일에 다음 변수들을 설정:

```hcl
# ECR 리포지토리 URL
ecr_repository_url = "404457776061.dkr.ecr.ap-northeast-2.amazonaws.com/backend-api"

# 데이터베이스 설정
db_name = "y2om_db"
db_username = "admin"
db_password = "your-password"

# Keycloak 설정
keycloak_client_secret = "your-client-secret"
keycloak_admin_username = "admin"
keycloak_admin_password = "admin"

# Meilisearch 설정
meilisearch_url = ""  # Kubernetes 서비스 사용 시 빈 값
meilisearch_api_key = "masterKey1234567890"
```

#### 배포 실행

```bash
cd /root/Terraform/07-domain-cf
terraform init
terraform apply -var-file=../terraform.tfvars -auto-approve
```

#### 배포 확인

```bash
# Pod 상태 확인
kubectl get pods -n formation-lap -l app=backend-api

# Service 확인
kubectl get svc -n formation-lap backend-api-service

# Ingress 확인
kubectl get ingress -n formation-lap msa-ingress
```

### Meilisearch 배포

Meilisearch는 `07-domain-cf` 스택에서 자동으로 배포됩니다.

#### 배포 확인

```bash
# Meilisearch Pod 확인
kubectl get pods -n formation-lap -l app=meilisearch

# Meilisearch Service 확인
kubectl get svc -n formation-lap meilisearch-service
```

자세한 내용은 [Backend API README.md](../Backend/README.md)의 "Meilisearch 배포 가이드" 섹션을 참고하세요.

---

## 테스트 가이드

### 1. API 엔드포인트 테스트

#### Swagger UI를 통한 테스트 (권장)

1. **Swagger UI 접속**
   ```
   https://api.exampleott.click/docs
   ```

2. **인증 토큰 발급**
   - `/api/v1/auth/login` 엔드포인트에서 로그인
   - 응답에서 `access_token` 복사
   - 우측 상단 "Authorize" 버튼 클릭하여 토큰 입력

3. **API 테스트**
   - 원하는 엔드포인트 선택
   - "Try it out" 클릭
   - 파라미터 입력 후 "Execute" 클릭

#### Search API 테스트

1. **컨텐츠 생성**
   - `/api/v1/contents` (POST) 엔드포인트 사용
   - Request body 예시:
     ```json
     {
       "title": "테스트 영화",
       "description": "검색 테스트를 위한 영화입니다",
       "age_rating": "ALL"
     }
     ```

2. **검색 테스트**
   - `/api/v1/search` (GET) 엔드포인트 사용
   - `q` 파라미터에 검색어 입력 (예: "테스트", "영화")
   - 결과 확인

#### curl을 통한 테스트

```bash
# 1. 토큰 발급
TOKEN=$(curl -s -X POST "https://api.exampleott.click/api/v1/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email": "test7@example.com", "password": "test1234"}' \
  -k | jq -r '.access_token')

# 2. Search API 테스트
curl -H "Authorization: Bearer $TOKEN" \
  "https://api.exampleott.click/api/v1/search?q=test" \
  -k | jq .

# 3. 컨텐츠 생성
curl -X POST "https://api.exampleott.click/api/v1/contents" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "테스트 영화", "description": "검색 테스트", "age_rating": "ALL"}' \
  -k | jq .
```

### 2. 인프라 상태 확인

#### Kubernetes 리소스 확인

```bash
# 모든 Pod 상태
kubectl get pods -n formation-lap

# Backend API Pod
kubectl get pods -n formation-lap -l app=backend-api

# Meilisearch Pod
kubectl get pods -n formation-lap -l app=meilisearch

# Service 확인
kubectl get svc -n formation-lap

# Ingress 확인
kubectl get ingress -n formation-lap
```

#### 로그 확인

```bash
# Backend API 로그
kubectl logs -n formation-lap -l app=backend-api --tail=50

# Meilisearch 로그
kubectl logs -n formation-lap -l app=meilisearch --tail=50
```

### 3. 데이터베이스 연결 확인

```bash
# RDS Proxy 엔드포인트 확인
cd /root/Terraform/03-database
terraform output kor_db_proxy_endpoint

# Backend API Pod에서 연결 테스트
kubectl exec -it -n formation-lap $(kubectl get pod -n formation-lap -l app=backend-api -o jsonpath='{.items[0].metadata.name}') -- \
  mysql -h <RDS_PROXY_ENDPOINT> -u admin -p
```

### 4. Meilisearch 직접 테스트

```bash
# Meilisearch Pod에 접속
MEILI_POD=$(kubectl get pod -n formation-lap -l app=meilisearch -o jsonpath='{.items[0].metadata.name}')

# Health Check
kubectl exec -n formation-lap $MEILI_POD -- curl -s http://localhost:7700/health

# 인덱스 확인
kubectl exec -n formation-lap $MEILI_POD -- \
  curl -s -H "Authorization: Bearer masterKey1234567890" \
  http://localhost:7700/indexes
```

---

## 문서 참조

### 주요 문서

- **[인프라_전체_흐름.md](./인프라_전체_흐름.md)**: 전체 인프라 구조와 데이터 흐름 상세 설명
- **[Backend API README.md](../Backend/README.md)**: Backend API 사용 가이드, JWT 토큰 발급, Meilisearch 배포 가이드

### 문제 해결 가이드

- **[BASTION_ACCESS_GUIDE.md](./BASTION_ACCESS_GUIDE.md)**: Bastion 호스트 접근 가이드
- **[SSH_TROUBLESHOOTING.md](./SSH_TROUBLESHOOTING.md)**: SSH 연결 문제 해결
- **[VPC_BACKEND_SETUP.md](./VPC_BACKEND_SETUP.md)**: VPC 및 Backend 설정 가이드

### 스크립트 설명

#### scripts/terraform-apply.sh

전체 인프라를 순서대로 배포하는 스크립트입니다.

```bash
cd /root/Terraform
./scripts/terraform-apply.sh
```

#### scripts/terraform-destroy.sh

전체 인프라를 삭제하는 스크립트입니다.

```bash
cd /root/Terraform
./scripts/terraform-destroy.sh
```

⚠️ **주의**: 이 스크립트는 모든 리소스를 삭제합니다. 신중하게 사용하세요.

---

## Git 협업 가이드

### 기본 워크플로우

1. **main 브랜치로 이동**
   ```bash
   git checkout main
   git pull origin main
   ```

2. **기능 브랜치 생성**
   ```bash
   git checkout -b feat/#이슈번호
   ```

3. **변경사항 커밋**
   ```bash
   git add .
   git commit -m "Feat: 기능 설명"
   ```

4. **브랜치 푸시**
   ```bash
   git push origin feat/#이슈번호
   ```

5. **Pull Request 생성**
   - GitHub에서 PR 생성
   - 리뷰 후 merge

### 커밋 메시지 규칙

- `Feat`: 새로운 기능 추가
- `Fix`: 버그 수정
- `Docs`: 문서 수정
- `Refactor`: 코드 리팩토링

예시:
```bash
git commit -m "Feat: Meilisearch 배포 추가"
git commit -m "Fix: Backend API 환경 변수 수정"
```

---

## 주의사항

### 보안

- `*.tfvars` 파일은 절대 Git에 커밋하지 마세요 (`.gitignore`에 포함됨)
- `*.tfstate` 파일도 Git에 커밋하지 마세요
- 민감한 정보는 AWS Secrets Manager 사용 권장

### 배포 순서

인프라는 순서대로 배포해야 합니다:
1. `01-infra` → 2. `02-kubernetes` → 3. `03-database` → ... → 10. `10-app-monitoring`

각 스택은 이전 스택의 Remote State를 참조합니다.

### 비용

각 리소스는 AWS 비용이 발생합니다. 불필요한 리소스는 삭제하세요.

---

## 문제 해결

### 일반적인 문제

1. **Terraform Apply 실패**
   - 이전 스택이 완료되었는지 확인
   - Remote State가 올바른지 확인
   - AWS 리소스 제한 확인

2. **Kubernetes 연결 실패**
   - `kubectl` 설정 확인: `kubectl get nodes`
   - EKS 클러스터 상태 확인

3. **API 접근 불가**
   - Ingress 상태 확인: `kubectl get ingress -n formation-lap`
   - ALB DNS 확인
   - ACM 인증서 상태 확인

자세한 문제 해결은 각 문서를 참고하세요.

---

## 추가 리소스

- [Terraform 공식 문서](https://www.terraform.io/docs)
- [AWS EKS 문서](https://docs.aws.amazon.com/eks/)
- [Kubernetes 공식 문서](https://kubernetes.io/docs/)

# Terraform 구조 통합 계획

## 📋 현재 상황 분석

### 현재 구조 (feat/#58 브랜치)
```
Terraform/
├── main.tf              # 기존 구조
├── providers.tf         # 기존 구조
├── variables.tf         # 기존 구조
├── modules/             # 기존 모듈들
│   ├── network/
│   ├── eks/
│   ├── database/
│   ├── domain/
│   └── ...
├── domain-access-logs/  # 새로 추가한 모듈
│   ├── main.tf
│   ├── variables.tf
│   ├── opensearch.tf
│   ├── lambda.tf
│   └── ...
└── scripts/
    └── terraform-apply.sh
```

### 새로운 구조 (main 브랜치)
```
Terraform/
├── 01-infra/           # 기본 인프라 (VPC, Network 등)
├── 02-kubernetes/      # EKS, Kubernetes 관련
├── 03-database/        # RDS, Database 관련
├── 04-addons/          # Addons (ALB Controller 등)
├── 05-argocd/          # ArgoCD
├── 06-certificate/     # ACM 인증서
├── 07-domain-cf/       # CloudFront 도메인
├── 08-domain-ga/       # Global Accelerator 도메인
├── modules/            # 재사용 가능한 모듈들
│   ├── waf/            # 새로 추가됨
│   └── ...
└── scripts/
    └── terraform-apply.sh (수정됨)
```

## 🎯 통합 전략

### Option 1: domain-access-logs를 새로운 구조에 맞게 통합 (권장)

**domain-access-logs는 Route53 Query Logging 기능이므로:**
- `09-domain-access-logs/` 디렉토리 생성
- 독립적인 스택으로 관리
- 다른 도메인 관련 스택과 유사한 구조

### Option 2: domain-access-logs를 modules로 유지

- `modules/domain-access-logs/`로 이동
- 다른 스택에서 재사용 가능하도록 모듈화

### Option 3: 07-domain-cf에 통합

- Route53 Query Logging은 도메인 관련 기능
- `07-domain-cf/`에 통합 가능

## ✅ 권장 방안: Option 1 (09-domain-access-logs/ 디렉토리 생성)

### 이유:
1. **독립성**: Route53 Query Logging은 독립적으로 관리하기 적합
2. **일관성**: 다른 numbered 디렉토리와 동일한 구조
3. **확장성**: 나중에 다른 로깅 기능 추가 시 확장 용이
4. **배포 순서**: 도메인 관련 작업 후에 실행 (09번이 적절)

## 📝 실행 계획

### Step 1: 새로운 디렉토리 구조 생성
```bash
mkdir -p 09-domain-access-logs
```

### Step 2: domain-access-logs 파일 이동 및 구조화
```
09-domain-access-logs/
├── main.tf           # Route53 Query Log 설정
├── providers.tf      # Provider 설정
├── variables.tf      # 변수 정의
├── outputs.tf        # 출력값 정의
├── opensearch.tf     # OpenSearch 도메인
├── lambda.tf         # Lambda 함수
├── iam.tf            # IAM 역할 및 정책
├── cloudwatch.tf     # CloudWatch Logs
├── route53.tf        # Route53 Query Log
└── lambda/           # Lambda 함수 코드
    └── index.py
```

### Step 3: scripts/terraform-apply.sh 수정
- 새로운 스택 추가
- 배포 순서 확인

### Step 4: 기존 파일 정리
- 루트의 main.tf, providers.tf, variables.tf는 이미 삭제됨 (main 브랜치에서)
- domain-access-logs/ 디렉토리 삭제 (이동 후)

## 🔄 마이그레이션 스크립트

단계별로 진행하겠습니다.

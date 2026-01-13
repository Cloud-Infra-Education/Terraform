# Terraform 프로젝트 가이드

## 목차
1. [스크립트 설명](#스크립트-설명)
2. [빠른 시작 가이드](#빠른-시작-가이드)
3. [테스트 가이드](#테스트-가이드)
4. [Git 협업 가이드](#git-협업-가이드)
5. [프로젝트 구조](#프로젝트-구조)
6. [현재 상태](#현재-상태)

---

## 스크립트 설명

### scripts/terraform-apply.sh 설명

이 스크립트 파일 단일실행으로 모든 인프라 구성이 가능합니다.

원하는 리소스만큼만 구성하는 것이 가능합니다.

1번 코드는 기본인프라 구성부터 ArgoCD, EKS, DB 설치까지 진행됩니다. 즉 2번, 3번, 4번으로 구축되는 인프라를 제외하고 모두 구축됩니다.

2번 코드는 ArgoCD 앱 설치를 진행합니다. ArgoCD 설치와 ArgoCD 앱은 별개입니다!  

3번 코드는 CloudFront, ACM 'ISSUE' 상태화, Ingress(ALB) 생성 작업이 진행됩니다.

  - Route53으로 등록한 도메인은 공동이기 때문에 이 단계는 다른 팀원과 겹치면 안됩니다.

4번 코드는 GA를 구성합니다.

### scripts/terraform-destroy.sh 설명

만약 terraform-apply.sh 에 있는 모든 실행코드를 apply 했다면 이 쉘파일 단일실행만으로 모든 인프라가 지워집니다.

if-1) terraform-apply.sh 의 4번 코드(GA) 실행을 안했다면 #GA 파트는 생략해주세요

if-1) terraform-apply.sh 의 3번 코드(Domain) 실행을 안했다면 #Domain 파트는 생략해주세요

if-2) terraform-apply.sh 의 2번 코드(ArgoCD앱) 실행을 안했다면 #ArgoCD 파트의 1,2번 라인을 생략해주세요

---

## 빠른 시작 가이드

### Domain Access Logs 적용 및 테스트

#### 1. Domain Access Logs 적용 (빠른 방법)

```bash
cd /root/Terraform
./apply-domain-access-logs.sh
```

또는 수동으로:

```bash
cd /root/Terraform/domain-access-logs
terraform init
terraform apply -var="route53_zone_id=Z038651135MZFV9GL29ON"
```

#### 2. 적용 후 Output 확인

```bash
cd /root/Terraform/domain-access-logs
terraform output
```

중요 정보:
- `opensearch_dashboard_url`: OpenSearch 대시보드 URL
- `lambda_function_name`: Lambda 함수 이름

#### 3. 간단한 테스트 (5분 내)

**Step 1: DNS 쿼리 생성**
```bash
# DNS 쿼리를 여러 번 실행하여 로그 생성
for i in {1..20}; do 
  dig matchacake.click +short
  sleep 2
done
```

**Step 2: CloudWatch Logs 확인**
```bash
# 로그가 생성되었는지 확인 (약 1-2분 후)
aws logs tail /aws/route53/y2om-query-logs --since 5m --format short
```

**Step 3: Lambda 실행 확인**
```bash
# Lambda 함수가 실행되었는지 확인
aws logs tail /aws/lambda/y2om-route53-dns-log-processor --since 5m --format short
```

**Step 4: OpenSearch 데이터 확인 (AWS CLI)**
```bash
# OpenSearch 엔드포인트 확인
cd /root/Terraform/domain-access-logs
OPENSEARCH_ENDPOINT=$(terraform output -raw opensearch_endpoint)
echo "OpenSearch Endpoint: $OPENSEARCH_ENDPOINT"
```

#### 4. AWS 콘솔에서 확인

1. **Route53 콘솔**
   - https://console.aws.amazon.com/route53/
   - Hosted zones > matchacake.click
   - "Query logging" 탭 확인

2. **CloudWatch Logs 콘솔**
   - https://console.aws.amazon.com/cloudwatch/
   - Log groups > `/aws/route53/y2om-query-logs`
   - 로그 이벤트 확인

3. **Lambda 콘솔**
   - https://console.aws.amazon.com/lambda/
   - Functions > `y2om-route53-dns-log-processor`
   - Monitor 탭 > Metrics 확인

4. **OpenSearch 콘솔**
   - https://console.aws.amazon.com/es/
   - Domains > `y2om-route53-dns-logs`
   - "OpenSearch Dashboards URL" 클릭

#### 5. 전체 인프라 적용 (선택사항)

전체 인프라를 적용하려면:

```bash
cd /root/Terraform
./scripts/terraform-apply.sh
```

⚠️ **주의**: 전체 인프라 적용은 시간이 오래 걸릴 수 있습니다 (30분~1시간).

---

## 테스트 가이드

### Domain Access Logs 상세 테스트 가이드

#### 1. Terraform Apply 실행

**메인 인프라 적용**
```bash
cd /root/Terraform
./scripts/terraform-apply.sh
```

**Domain Access Logs 적용**
```bash
cd /root/Terraform/domain-access-logs

# Route53 Zone ID 확인 (필요시)
aws route53 list-hosted-zones --query 'HostedZones[?Name==`matchacake.click.`].Id' --output text

# Terraform 적용 (route53_zone_id 변수 필요)
terraform init
terraform apply -var="route53_zone_id=<YOUR_ZONE_ID>"
```

#### 2. 리소스 확인

**Terraform Output 확인**
```bash
cd /root/Terraform/domain-access-logs
terraform output
```

출력 정보:
- `opensearch_endpoint`: OpenSearch 엔드포인트
- `opensearch_dashboard_url`: OpenSearch 대시보드 URL
- `lambda_function_name`: Lambda 함수 이름
- `cloudwatch_log_group_arn`: CloudWatch Log Group ARN

#### 3. 테스트 방법

##### 3.1 DNS 쿼리 생성 (테스트 트래픽 생성)

도메인에 DNS 쿼리를 실행하여 로그를 생성합니다:

```bash
# nslookup 사용
nslookup matchacake.click

# dig 사용 (더 많은 쿼리)
dig matchacake.click
dig www.matchacake.click
dig api.matchacake.click

# 여러 번 실행하여 로그 생성
for i in {1..10}; do dig matchacake.click +short; sleep 1; done
```

##### 3.2 CloudWatch Logs 확인

```bash
# Log Group 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/route53/y2om-query-logs" --query 'logGroups[0]'

# 로그 스트림 확인
LOG_GROUP_NAME="/aws/route53/y2om-query-logs"
aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --order-by LastEventTime --descending --max-items 5

# 최근 로그 이벤트 확인
aws logs tail "$LOG_GROUP_NAME" --follow --format short
```

##### 3.3 Lambda 함수 확인

```bash
# Lambda 함수 상태 확인
aws lambda get-function --function-name y2om-route53-dns-log-processor --query 'Configuration.{FunctionName:FunctionName,State:State,LastModified:LastModified}'

# Lambda 로그 확인 (Lambda 실행 로그)
aws logs tail /aws/lambda/y2om-route53-dns-log-processor --follow --format short

# Lambda 함수 수동 테스트 (선택사항)
aws lambda invoke --function-name y2om-route53-dns-log-processor --payload '{"test":"data"}' response.json
cat response.json
```

##### 3.4 OpenSearch 대시보드 접근

1. **OpenSearch Dashboard URL 확인**
   ```bash
   cd /root/Terraform/domain-access-logs
   terraform output opensearch_dashboard_url
   ```

2. **대시보드 접근**
   - 출력된 URL로 브라우저 접근
   - IAM 인증 필요 (Lambda 역할의 IAM 자격증명 사용)
   - 또는 EC2에서 임시 IAM 역할을 통해 접근

3. **인덱스 확인**
   - 왼쪽 메뉴에서 "Management" > "Index Management" 선택
   - `y2om-route53-dns-logs` 인덱스 확인

4. **데이터 검색**
   - 왼쪽 메뉴에서 "Discover" 선택
   - Index pattern: `y2om-route53-dns-logs` 선택
   - 데이터 확인

##### 3.5 AWS 콘솔에서 확인

1. **Route53 콘솔**
   - Route53 > Hosted zones > matchacake.click
   - "Query logging" 탭에서 활성화 상태 확인

2. **CloudWatch Logs 콘솔**
   - CloudWatch > Log groups
   - `/aws/route53/y2om-query-logs` 확인
   - 로그 스트림과 이벤트 확인

3. **Lambda 콘솔**
   - Lambda > Functions > y2om-route53-dns-log-processor
   - "Monitor" 탭에서 실행 횟수, 오류 확인
   - "Logs" 탭에서 CloudWatch Logs 확인

4. **OpenSearch 콘솔**
   - OpenSearch Service > Domains > y2om-route53-dns-logs
   - 도메인 상태 확인
   - "OpenSearch Dashboards URL" 클릭하여 접근

#### 4. 데이터 검증

**OpenSearch 쿼리 예시**

OpenSearch Dashboard의 Dev Tools에서 실행:

```json
# 인덱스 확인
GET _cat/indices/y2om-route53-dns-logs?v

# 최근 데이터 조회
GET y2om-route53-dns-logs/_search
{
  "size": 20,
  "sort": [
    {
      "timestamp": {
        "order": "desc"
      }
    }
  ]
}

# 특정 도메인 조회
GET y2om-route53-dns-logs/_search
{
  "query": {
    "match": {
      "domain": "matchacake.click"
    }
  }
}

# 통계 조회
GET y2om-route53-dns-logs/_search
{
  "size": 0,
  "aggs": {
    "domains": {
      "terms": {
        "field": "domain.keyword",
        "size": 10
      }
    },
    "query_types": {
      "terms": {
        "field": "query_type.keyword",
        "size": 10
      }
    }
  }
}
```

#### 5. 문제 해결

**로그가 생성되지 않는 경우**
- Route53 Query Logging이 활성화되었는지 확인
- CloudWatch Log Resource Policy가 올바르게 설정되었는지 확인
- DNS 쿼리가 실제로 발생했는지 확인

**Lambda가 실행되지 않는 경우**
- CloudWatch Logs Subscription Filter가 올바르게 설정되었는지 확인
- Lambda 권한 (lambda_permission) 확인
- Lambda 함수 로그에서 오류 확인

**OpenSearch에 데이터가 없는 경우**
- Lambda 함수 로그 확인
- OpenSearch 인덱스가 생성되었는지 확인
- Lambda IAM 역할에 OpenSearch 접근 권한 확인
- OpenSearch 도메인 상태 확인 (활성화되어 있는지)

#### 6. 모니터링

**CloudWatch 메트릭 확인**
```bash
# Lambda 실행 횟수
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Invocations \
  --dimensions Name=FunctionName,Value=y2om-route53-dns-log-processor \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum

# Lambda 오류 횟수
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Errors \
  --dimensions Name=FunctionName,Value=y2om-route53-dns-log-processor \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Sum
```

---

## Git 협업 가이드

### GitHub 푸시 가이드

#### 워크플로우 (이슈 #58 기준)

**STEP 1: main 브랜치로 이동**
```bash
git checkout main
```

**STEP 2: 최신 코드 가져오기**
```bash
git pull origin main
```

**STEP 3: GitHub에서 이슈 생성 후 브랜치 만들기**
- GitHub에서 이슈 #58 생성 (이미 생성되어 있으면 생략)
- 브랜치 명명 규칙: `feat/#이슈번호`
- 로컬에서 브랜치 생성:
```bash
git checkout -b feat/#58
```

**STEP 4: 수정(기능 추가 및 수정)**
- 파일 수정 작업 수행
- Terraform 코드 변경 등

**STEP 5: 작업 저장**
```bash
git add .
# 또는 특정 파일만
git add <파일명>
```

**STEP 6: 커밋 메시지**
```bash
git commit -m "Feat: 내가 만든 기능"
```

**커밋 메시지 예시:**
```bash
git commit -m "Feat: OpenSearch Fine-grained access control 활성화"
git commit -m "Feat: Route53 Query Logging 설정 추가"
git commit -m "Fix: Lambda 환경 변수 오류 수정"
```

**STEP 7: 내 브랜치 GitHub에 올리기**
```bash
git push origin feat/#58
```

**첫 푸시인 경우:**
```bash
git push -u origin feat/#58
# -u 옵션: upstream 설정 (다음부터 git push만 해도 됨)
```

#### 커밋 메시지 가이드

**커밋 타입**
- `Feat`: 새로운 기능 추가
- `Fix`: 버그 수정
- `Docs`: 문서 수정
- `Style`: 코드 포맷팅, 세미콜론 누락 등
- `Refactor`: 코드 리팩토링
- `Test`: 테스트 코드 추가/수정
- `Chore`: 빌드 업무 수정, 패키지 매니저 설정 등

**예시**
```bash
git commit -m "Feat: OpenSearch Fine-grained access control 활성화 (#58)"
git commit -m "Fix: Lambda AWS_REGION 환경 변수 오류 수정"
git commit -m "Feat: Route53 Query Logging 설정 추가 (#58)"
```

#### 주의사항

**브랜치 명명 규칙**
- ✅ `feat/#58`
- ✅ `feat/#이슈번호`
- ❌ `feat-58` (이슈 번호 앞에 # 필요)
- ❌ `feature/#58` (규칙과 다름)

**푸시 전 확인**
```bash
# 변경사항 확인
git status

# 커밋 내용 확인
git log --oneline -1

# 어떤 파일이 변경되었는지 확인
git diff --name-only HEAD~1
```

**실수 방지**
```bash
# ❌ main 브랜치에 직접 푸시하지 않기
git checkout main
git push origin main  # 주의!

# ✅ 기능 브랜치에서만 푸시
git checkout feat/#58
git push origin feat/#58  # 안전
```

#### GitHub에서 Pull Request 생성

1. GitHub 저장소로 이동
2. "Compare & pull request" 버튼 클릭 (푸시 후 자동 표시)
3. PR 제목 및 설명 작성
4. 리뷰어 지정
5. "Create pull request" 클릭

#### 유용한 명령어

```bash
# 현재 브랜치 확인
git branch

# 브랜치 목록 확인 (원격 포함)
git branch -a

# 브랜치 전환
git checkout <브랜치명>

# 최신 상태로 업데이트
git fetch origin
git pull origin main

# 커밋 전 변경사항 확인
git diff

# 스테이징된 변경사항 확인
git diff --staged

# 커밋 히스토리 확인
git log --oneline --graph -10
```

### Git 협업 안전 가이드

#### 상황
- GitHub의 main 브랜치에 다른 조원이 변경사항을 push함
- 로컬에 아직 커밋/푸시하지 않은 변경사항이 있음
- 최신 main을 받아오면서 충돌을 해결해야 함

#### 단계별 안전한 작업 절차

**STEP 1: 현재 작업 상태 확인**

```bash
# 현재 브랜치 확인
git branch

# 변경사항 상태 확인
git status

# 변경된 파일 목록 확인
git diff --name-only
```

**확인 사항:**
- 현재 어떤 브랜치에 있는지
- 어떤 파일이 변경되었는지
- 추적되지 않는 파일이 있는지

**STEP 2: 로컬 변경사항 안전하게 보호하기** ⚠️ **중요**

로컬 변경사항을 잃지 않기 위해 두 가지 방법 중 선택:

**방법 A: Stash 사용 (임시 저장) - 권장**

```bash
# 현재 변경사항을 임시 저장 (워킹 디렉토리만 깨끗하게)
git stash push -m "작업 중: OpenSearch Fine-grained access control 설정"

# stash 목록 확인
git stash list

# 나중에 다시 적용하려면
git stash pop  # 또는 git stash apply
```

**장점:**
- 빠르게 저장 가능
- 커밋 히스토리 오염 없음
- 필요시 쉽게 복구 가능

**주의사항:**
- `.gitignore`에 포함된 파일은 stash되지 않음
- 추적되지 않는 새 파일도 stash되지 않을 수 있음

**방법 B: 별도 브랜치에 커밋 (더 안전)**

```bash
# 현재 작업을 위한 새 브랜치 생성
git checkout -b feature/opensearch-fgac

# 변경사항 스테이징
git add .

# 커밋 (되돌릴 수 있도록)
git commit -m "WIP: OpenSearch Fine-grained access control 설정"

# 이제 안전하게 main으로 돌아갈 수 있음
git checkout main
```

**장점:**
- 변경사항이 영구적으로 보존됨
- 여러 번 되돌릴 수 있음
- 나중에 브랜치로 작업 계속 가능

**STEP 3: 최신 main 브랜치 받아오기**

```bash
# 현재 main 브랜치에 있는지 확인
git checkout main

# 원격 저장소의 최신 정보 가져오기 (병합하지 않음)
git fetch origin

# 원격 main과 로컬 main의 차이 확인
git log HEAD..origin/main --oneline

# 원격 main의 변경사항을 로컬 main에 병합
git pull origin main
```

**또는 더 안전한 방법:**

```bash
# fetch로만 가져오기
git fetch origin

# 차이 확인
git diff main origin/main

# 수동으로 merge (더 제어 가능)
git merge origin/main
```

**STEP 4: 충돌(Conflict) 해결하기**

**4-1. 충돌 발생 확인**

```bash
# 충돌이 발생하면 Git이 알려줌
# Auto-merging 실패 메시지 확인

# 충돌된 파일 목록 확인
git status
# "Unmerged paths:" 섹션 확인
```

**4-2. 충돌 파일 확인**

```bash
# 충돌 마커가 있는 파일 확인
# <<<<<<< HEAD
# 로컬 변경사항
# =======
# 원격 변경사항
# >>>>>>> origin/main

# 특정 파일의 충돌 내용 확인
git diff <충돌된 파일명>
```

**4-3. Terraform 코드 충돌 해결 요령**

**예시: Terraform 파일 충돌**

```hcl
# 충돌 예시
<<<<<<< HEAD
  advanced_security_options {
    enabled = true
    master_user_options {
      master_user_name = "admin"
      master_user_password = "ChangeMe123!"
    }
  }
=======
  advanced_security_options {
    enabled = false
  }
>>>>>>> origin/main
```

**해결 방법:**

1. **충돌 내용 분석**
   ```bash
   # 충돌 파일 열기
   vim domain-access-logs/opensearch.tf
   # 또는
   code domain-access-logs/opensearch.tf
   ```

2. **수동으로 병합**
   - `<<<<<<< HEAD` ~ `=======` 사이: **내 변경사항**
   - `=======` ~ `>>>>>>> origin/main` 사이: **원격 변경사항**
   - 두 변경사항을 **의미있게 합치기**

3. **올바른 버전 선택**
   ```hcl
   # 최종 결과 (두 변경사항 통합)
   advanced_security_options {
     enabled = true
     internal_user_database_enabled = true
     master_user_options {
       master_user_name     = "admin"
       master_user_password = var.opensearch_master_user_password
     }
   }
   ```

4. **충돌 마커 제거**
   - `<<<<<<<`, `=======`, `>>>>>>>` 모두 삭제
   - 코드가 문법적으로 올바른지 확인

**4-4. 충돌 해결 후 스테이징**

```bash
# 충돌 해결 완료된 파일 스테이징
git add <해결한 파일명>

# 모든 충돌 해결 확인
git status
# "Unmerged paths"가 없어야 함

# Terraform 코드 검증 (선택사항)
terraform validate
terraform fmt -check
```

**STEP 5: 병합 완료 및 푸시**

**5-1. Stash를 사용한 경우**

```bash
# 병합 완료 후 stash 적용
git stash pop

# 다시 충돌이 발생할 수 있음 → STEP 4 반복
# 또는 충돌 없으면 정상적으로 적용됨
```

**5-2. 병합 커밋 완료**

```bash
# merge commit이 자동으로 생성됨
# 또는 명시적으로 커밋 (필요시)
git commit -m "Merge origin/main: OpenSearch FGAC 설정 병합"

# 커밋 로그 확인
git log --oneline --graph -10
```

**5-3. 원격 저장소에 푸시**

```bash
# 현재 상태 확인
git status

# 원격 저장소에 푸시
git push origin main

# 또는 브랜치를 사용한 경우
git push origin feature/opensearch-fgac
```

#### 실수하면 안 되는 포인트

**절대 하면 안 되는 명령어**

```bash
# ❌ 위험: 로컬 변경사항 강제 덮어쓰기
git reset --hard origin/main  # 로컬 변경사항 모두 삭제!

# ❌ 위험: 충돌 무시하고 강제 푸시
git push --force origin main  # 다른 사람 작업 덮어씀!

# ❌ 위험: stash 목록 확인 없이 clear
git stash clear  # stash 모두 삭제!
```

**주의해야 할 명령어**

```bash
# ⚠️ 주의: 변경사항 확인 후 사용
git reset --hard HEAD  # 현재 커밋으로 되돌림 (변경사항 삭제)
git clean -fd  # 추적되지 않는 파일 삭제
```

**안전한 되돌리기 방법**

```bash
# 변경사항 확인
git status
git diff

# 되돌리기 (안전)
git restore <파일명>  # 특정 파일만 되돌리기
git restore .  # 모든 변경사항 되돌리기 (staged 제외)

# staged 되돌리기
git restore --staged <파일명>
```

#### 추가 안전 조치

**1. 작업 전 백업 (선택사항)**

```bash
# 현재 브랜치를 백업 브랜치로 복사
git branch backup-$(date +%Y%m%d-%H%M%S)
```

**2. 원격 변경사항 미리 확인**

```bash
# fetch만 하고 merge는 나중에
git fetch origin

# 어떤 파일이 변경되었는지 확인
git diff main origin/main --name-only

# 변경 내용 미리보기
git diff main origin/main
```

**3. 작은 단위로 작업**

```bash
# 여러 파일을 한 번에 변경하지 말고
# 파일별로 커밋 분리 (선택사항)
git add file1.tf
git commit -m "feat: file1 변경"
git add file2.tf
git commit -m "feat: file2 변경"
```

#### 체크리스트

**작업 전:**
- [ ] `git status`로 현재 상태 확인
- [ ] 로컬 변경사항 stash 또는 커밋
- [ ] `git fetch origin`으로 원격 정보 가져오기
- [ ] `git log HEAD..origin/main`로 변경사항 확인

**충돌 해결:**
- [ ] `git status`로 충돌 파일 목록 확인
- [ ] 각 파일의 충돌 마커 확인 및 해결
- [ ] `terraform validate`로 코드 검증
- [ ] `git add`로 해결한 파일 스테이징
- [ ] `git status`로 모든 충돌 해결 확인

**푸시 전:**
- [ ] `git log`로 커밋 히스토리 확인
- [ ] `terraform plan`으로 인프라 변경 확인 (Terraform의 경우)
- [ ] `git push` 실행

#### 전체 워크플로우 요약

```bash
# 1. 상태 확인
git status

# 2. 로컬 변경사항 보호
git stash push -m "작업 내용 설명"

# 3. 최신 main 받기
git checkout main
git fetch origin
git pull origin main  # 또는 git merge origin/main

# 4. 충돌 해결 (발생시)
# - 충돌 파일 편집
# - git add <파일>
# - git commit (merge commit)

# 5. stash 복구
git stash pop

# 6. 추가 충돌 해결 (필요시)
# - STEP 4 반복

# 7. 푸시
git push origin main
```

#### Terraform 특화 팁

**Terraform State 충돌 주의**

```bash
# ⚠️ Terraform state 파일은 절대 병합하지 말 것!
# .terraform.tfstate, terraform.tfstate.backup 등

# .gitignore 확인
cat .gitignore | grep -i terraform

# state 파일은 원격 백엔드 사용 권장
# (S3, Terraform Cloud 등)
```

**변수 파일 주의**

```bash
# secrets가 포함된 .tfvars 파일도 주의
# 예: terraform.tfvars, *.auto.tfvars

# .gitignore에 추가되어 있는지 확인
```

#### 참고 명령어 모음

```bash
# 상태 확인
git status
git log --oneline --graph --all -20
git diff
git diff --name-only

# 안전한 되돌리기
git restore <파일>
git restore --staged <파일>
git reset --soft HEAD~1  # 커밋만 취소, 변경사항 유지

# 브랜치 관리
git branch -a  # 모든 브랜치 확인
git branch -d <브랜치>  # 로컬 브랜치 삭제
git branch -D <브랜치>  # 강제 삭제

# 원격 관리
git remote -v  # 원격 저장소 확인
git fetch origin  # 원격 정보 가져오기 (병합 안함)
git pull origin main  # fetch + merge
```

---

## 프로젝트 구조

### Terraform 구조 통합 계획

#### 현재 구조 (feat/#58 브랜치)
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

#### 새로운 구조 (main 브랜치)
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

#### 통합 전략

**Option 1: domain-access-logs를 새로운 구조에 맞게 통합 (권장)**

**domain-access-logs는 Route53 Query Logging 기능이므로:**
- `09-domain-access-logs/` 디렉토리 생성
- 독립적인 스택으로 관리
- 다른 도메인 관련 스택과 유사한 구조

**Option 2: domain-access-logs를 modules로 유지**

- `modules/domain-access-logs/`로 이동
- 다른 스택에서 재사용 가능하도록 모듈화

**Option 3: 07-domain-cf에 통합**

- Route53 Query Logging은 도메인 관련 기능
- `07-domain-cf/`에 통합 가능

#### 권장 방안: Option 1 (09-domain-access-logs/ 디렉토리 생성)

**이유:**
1. **독립성**: Route53 Query Logging은 독립적으로 관리하기 적합
2. **일관성**: 다른 numbered 디렉토리와 동일한 구조
3. **확장성**: 나중에 다른 로깅 기능 추가 시 확장 용이
4. **배포 순서**: 도메인 관련 작업 후에 실행 (09번이 적절)

#### 실행 계획

**Step 1: 새로운 디렉토리 구조 생성**
```bash
mkdir -p 09-domain-access-logs
```

**Step 2: domain-access-logs 파일 이동 및 구조화**
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

**Step 3: scripts/terraform-apply.sh 수정**
- 새로운 스택 추가
- 배포 순서 확인

**Step 4: 기존 파일 정리**
- 루트의 main.tf, providers.tf, variables.tf는 이미 삭제됨 (main 브랜치에서)
- domain-access-logs/ 디렉토리 삭제 (이동 후)

---

## 현재 상태

### Terraform Apply 상태

#### 현재 상태 (2026-01-11)

**✅ 완료된 리소스**
- VPC, Subnets, Route Tables (KOR, USA)
- Transit Gateway 및 Peering
- VPN 연결
- S3 버킷
- ECR 리포지토리
- RDS 클러스터 및 Proxy
- EKS 클러스터 (Seoul, Oregon)
- EKS 노드 그룹

**⏳ 진행 중**
- EKS 클러스터 활성화 (Kubernetes API 서버 준비 중)
- Helm releases (Cluster Autoscaler, ArgoCD) - 클러스터 활성화 대기 중

**📝 다음 단계**

클러스터가 활성화되면 (약 2-5분 후):

```bash
cd /root/Terraform
terraform apply -auto-approve
```

또는 스크립트의 다음 단계를 실행:

```bash
cd /root/Terraform
./scripts/terraform-apply.sh
```

스크립트는 자동으로:
1. 기본 인프라 구성 ✅ (완료)
2. ArgoCD 앱 설치 (클러스터 활성화 후 진행)
3. Domain 설정 (CloudFront, ACM, Ingress)
4. Global Accelerator 구성

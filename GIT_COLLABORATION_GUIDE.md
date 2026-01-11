# Git 협업 안전 가이드

## 🎯 상황
- GitHub의 main 브랜치에 다른 조원이 변경사항을 push함
- 로컬에 아직 커밋/푸시하지 않은 변경사항이 있음
- 최신 main을 받아오면서 충돌을 해결해야 함

---

## 📋 단계별 안전한 작업 절차

### **STEP 1: 현재 작업 상태 확인**

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

---

### **STEP 2: 로컬 변경사항 안전하게 보호하기** ⚠️ **중요**

로컬 변경사항을 잃지 않기 위해 두 가지 방법 중 선택:

#### **방법 A: Stash 사용 (임시 저장) - 권장**

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

#### **방법 B: 별도 브랜치에 커밋 (더 안전)**

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

---

### **STEP 3: 최신 main 브랜치 받아오기**

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

---

### **STEP 4: 충돌(Conflict) 해결하기**

#### **4-1. 충돌 발생 확인**

```bash
# 충돌이 발생하면 Git이 알려줌
# Auto-merging 실패 메시지 확인

# 충돌된 파일 목록 확인
git status
# "Unmerged paths:" 섹션 확인
```

#### **4-2. 충돌 파일 확인**

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

#### **4-3. Terraform 코드 충돌 해결 요령**

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

#### **4-4. 충돌 해결 후 스테이징**

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

---

### **STEP 5: 병합 완료 및 푸시**

#### **5-1. Stash를 사용한 경우**

```bash
# 병합 완료 후 stash 적용
git stash pop

# 다시 충돌이 발생할 수 있음 → STEP 4 반복
# 또는 충돌 없으면 정상적으로 적용됨
```

#### **5-2. 병합 커밋 완료**

```bash
# merge commit이 자동으로 생성됨
# 또는 명시적으로 커밋 (필요시)
git commit -m "Merge origin/main: OpenSearch FGAC 설정 병합"

# 커밋 로그 확인
git log --oneline --graph -10
```

#### **5-3. 원격 저장소에 푸시**

```bash
# 현재 상태 확인
git status

# 원격 저장소에 푸시
git push origin main

# 또는 브랜치를 사용한 경우
git push origin feature/opensearch-fgac
```

---

## ⚠️ 실수하면 안 되는 포인트

### **절대 하면 안 되는 명령어**

```bash
# ❌ 위험: 로컬 변경사항 강제 덮어쓰기
git reset --hard origin/main  # 로컬 변경사항 모두 삭제!

# ❌ 위험: 충돌 무시하고 강제 푸시
git push --force origin main  # 다른 사람 작업 덮어씀!

# ❌ 위험: stash 목록 확인 없이 clear
git stash clear  # stash 모두 삭제!
```

### **주의해야 할 명령어**

```bash
# ⚠️ 주의: 변경사항 확인 후 사용
git reset --hard HEAD  # 현재 커밋으로 되돌림 (변경사항 삭제)
git clean -fd  # 추적되지 않는 파일 삭제
```

### **안전한 되돌리기 방법**

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

---

## 🛡️ 추가 안전 조치

### **1. 작업 전 백업 (선택사항)**

```bash
# 현재 브랜치를 백업 브랜치로 복사
git branch backup-$(date +%Y%m%d-%H%M%S)
```

### **2. 원격 변경사항 미리 확인**

```bash
# fetch만 하고 merge는 나중에
git fetch origin

# 어떤 파일이 변경되었는지 확인
git diff main origin/main --name-only

# 변경 내용 미리보기
git diff main origin/main
```

### **3. 작은 단위로 작업**

```bash
# 여러 파일을 한 번에 변경하지 말고
# 파일별로 커밋 분리 (선택사항)
git add file1.tf
git commit -m "feat: file1 변경"
git add file2.tf
git commit -m "feat: file2 변경"
```

---

## 📝 체크리스트

작업 전:
- [ ] `git status`로 현재 상태 확인
- [ ] 로컬 변경사항 stash 또는 커밋
- [ ] `git fetch origin`으로 원격 정보 가져오기
- [ ] `git log HEAD..origin/main`로 변경사항 확인

충돌 해결:
- [ ] `git status`로 충돌 파일 목록 확인
- [ ] 각 파일의 충돌 마커 확인 및 해결
- [ ] `terraform validate`로 코드 검증
- [ ] `git add`로 해결한 파일 스테이징
- [ ] `git status`로 모든 충돌 해결 확인

푸시 전:
- [ ] `git log`로 커밋 히스토리 확인
- [ ] `terraform plan`으로 인프라 변경 확인 (Terraform의 경우)
- [ ] `git push` 실행

---

## 🔄 전체 워크플로우 요약

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

---

## 💡 Terraform 특화 팁

### **Terraform State 충돌 주의**

```bash
# ⚠️ Terraform state 파일은 절대 병합하지 말 것!
# .terraform.tfstate, terraform.tfstate.backup 등

# .gitignore 확인
cat .gitignore | grep -i terraform

# state 파일은 원격 백엔드 사용 권장
# (S3, Terraform Cloud 등)
```

### **변수 파일 주의**

```bash
# secrets가 포함된 .tfvars 파일도 주의
# 예: terraform.tfvars, *.auto.tfvars

# .gitignore에 추가되어 있는지 확인
```

---

## 📚 참고 명령어 모음

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

# GitHub 푸시 가이드

## 📋 워크플로우 (이슈 #58 기준)

### **STEP 1: main 브랜치로 이동**
```bash
git checkout main
```

### **STEP 2: 최신 코드 가져오기**
```bash
git pull origin main
```

### **STEP 3: GitHub에서 이슈 생성 후 브랜치 만들기**
- GitHub에서 이슈 #58 생성 (이미 생성되어 있으면 생략)
- 브랜치 명명 규칙: `feat/#이슈번호`
- 로컬에서 브랜치 생성:
```bash
git checkout -b feat/#58
```

### **STEP 4: 수정(기능 추가 및 수정)**
- 파일 수정 작업 수행
- Terraform 코드 변경 등

### **STEP 5: 작업 저장**
```bash
git add .
# 또는 특정 파일만
git add <파일명>
```

### **STEP 6: 커밋 메시지**
```bash
git commit -m "Feat: 내가 만든 기능"
```

**커밋 메시지 예시:**
```bash
git commit -m "Feat: OpenSearch Fine-grained access control 활성화"
git commit -m "Feat: Route53 Query Logging 설정 추가"
git commit -m "Fix: Lambda 환경 변수 오류 수정"
```

### **STEP 7: 내 브랜치 GitHub에 올리기**
```bash
git push origin feat/#58
```

**첫 푸시인 경우:**
```bash
git push -u origin feat/#58
# -u 옵션: upstream 설정 (다음부터 git push만 해도 됨)
```

---

## 🎯 현재 작업에 적용

### OpenSearch Fine-grained access control 설정

```bash
# 1. main으로 이동
git checkout main

# 2. 최신 코드 가져오기
git pull origin main

# 3. 브랜치 생성
git checkout -b feat/#58

# 4. 변경사항 스테이징
git add .

# 5. 커밋
git commit -m "Feat: OpenSearch Fine-grained access control 활성화 (#58)"

# 6. 푸시
git push origin feat/#58
```

---

## 📝 커밋 메시지 가이드

### 커밋 타입
- `Feat`: 새로운 기능 추가
- `Fix`: 버그 수정
- `Docs`: 문서 수정
- `Style`: 코드 포맷팅, 세미콜론 누락 등
- `Refactor`: 코드 리팩토링
- `Test`: 테스트 코드 추가/수정
- `Chore`: 빌드 업무 수정, 패키지 매니저 설정 등

### 예시
```bash
git commit -m "Feat: OpenSearch Fine-grained access control 활성화 (#58)"
git commit -m "Fix: Lambda AWS_REGION 환경 변수 오류 수정"
git commit -m "Feat: Route53 Query Logging 설정 추가 (#58)"
```

---

## ⚠️ 주의사항

### 브랜치 명명 규칙
- ✅ `feat/#58`
- ✅ `feat/#이슈번호`
- ❌ `feat-58` (이슈 번호 앞에 # 필요)
- ❌ `feature/#58` (규칙과 다름)

### 푸시 전 확인
```bash
# 변경사항 확인
git status

# 커밋 내용 확인
git log --oneline -1

# 어떤 파일이 변경되었는지 확인
git diff --name-only HEAD~1
```

### 실수 방지
```bash
# ❌ main 브랜치에 직접 푸시하지 않기
git checkout main
git push origin main  # 주의!

# ✅ 기능 브랜치에서만 푸시
git checkout feat/#58
git push origin feat/#58  # 안전
```

---

## 🔄 GitHub에서 Pull Request 생성

1. GitHub 저장소로 이동
2. "Compare & pull request" 버튼 클릭 (푸시 후 자동 표시)
3. PR 제목 및 설명 작성
4. 리뷰어 지정
5. "Create pull request" 클릭

---

## 🛠️ 유용한 명령어

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

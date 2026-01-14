# FastAPI /docs 경로 문제 해결 방안

## 현재 상황

- ✅ Keycloak: `https://api.matchacake.click/keycloak` 정상 작동
- ❌ FastAPI /docs: `https://api.matchacake.click/api/docs` 404 에러
- ✅ API 엔드포인트: `https://api.matchacake.click/api/v1/health` 정상 작동

## 문제 원인

백엔드 로그를 보면:
- 백엔드가 루트 경로(`/`)에서 200 OK 반환
- `/api/docs` 요청 시 404 Not Found
- FastAPI의 Swagger UI가 비활성화되었거나 다른 경로를 사용 중일 가능성

## 해결 방법

### 방법 1: 백엔드 코드 수정 (권장)

백엔드 코드에서 FastAPI 앱 생성 시 다음을 확인:

```python
from fastapi import FastAPI

app = FastAPI(
    title="Backend API",
    docs_url="/docs",  # Swagger UI 활성화
    redoc_url="/redoc",  # ReDoc 활성화
    openapi_url="/openapi.json",  # OpenAPI 스키마 활성화
    root_path="/api"  # Ingress의 /api prefix를 위해
)
```

또는 환경 변수로:
```python
import os

app = FastAPI(
    root_path=os.getenv("ROOT_PATH", ""),
    docs_url="/docs" if os.getenv("ENABLE_DOCS", "true") == "true" else None
)
```

### 방법 2: 백엔드 ConfigMap에 환경 변수 추가

이미 `ROOT_PATH=/api`를 추가했지만, 백엔드 코드가 이를 사용하지 않을 수 있습니다.

추가로 확인할 환경 변수:
- `ENABLE_DOCS=true`
- `DOCS_URL=/docs`

### 방법 3: 백엔드 코드 확인

백엔드 코드 저장소에서 다음을 확인:
1. `docs_url` 파라미터가 `None`으로 설정되어 있는지
2. `include_in_schema=False`로 설정된 엔드포인트가 있는지
3. 커스텀 라우터에서 `/docs` 경로를 차단하고 있는지

## 현재 설정

- ✅ Ingress에 `/docs` 경로 추가됨
- ✅ ConfigMap에 `ROOT_PATH=/api` 추가됨
- ⚠️ 백엔드 코드에서 이를 사용하는지 확인 필요

## 테스트 명령어

```bash
# Keycloak 확인
curl -L https://api.matchacake.click/keycloak

# API Health 확인
curl https://api.matchacake.click/api/v1/health

# Docs 경로 테스트
curl https://api.matchacake.click/api/docs
curl https://api.matchacake.click/docs
curl https://api.matchacake.click/api/v1/docs
```

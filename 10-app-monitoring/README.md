# 10-app-monitoring: 애플리케이션 모니터링

## 개요

로그, 메트릭, 트레이스 수집 및 모니터링을 담당하는 단계입니다.

## 구성 요소

### 1. Loki
- 로그 수집 및 저장
- S3 백엔드 사용

### 2. Mimir
- 메트릭 수집 및 저장
- Prometheus 호환

### 3. Tempo
- 분산 추적 (Distributed Tracing)
- OTLP 프로토콜 지원

### 4. Grafana
- 통합 대시보드
- Loki, Mimir, Tempo 데이터 시각화

### 5. Alloy
- 로그, 메트릭, 트레이스 수집 에이전트
- Kubernetes Pod 로그 자동 수집

## 배포 위치

**AWS에서 별도로 실행되는 리소스:**
- S3 버킷 (Loki, Mimir, Tempo 백엔드)

**EKS에 배포되는 리소스:**
- Loki (Pod)
- Mimir (Pod)
- Tempo (Pod)
- Grafana (Pod)
- Alloy (DaemonSet)

## 배포 방법

```bash
cd 10-app-monitoring
terraform init
terraform plan
terraform apply
```

## 의존성

- `02-kubernetes` (EKS 클러스터 필요)

## 참고

모니터링 스택은 선택사항이며, 프로덕션 환경에서 권장됩니다.

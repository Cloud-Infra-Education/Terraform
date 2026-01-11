# Domain Access Logs 테스트 가이드

## 1. Terraform Apply 실행

### 메인 인프라 적용
```bash
cd /root/Terraform
./scripts/terraform-apply.sh
```

### Domain Access Logs 적용
```bash
cd /root/Terraform/domain-access-logs

# Route53 Zone ID 확인 (필요시)
aws route53 list-hosted-zones --query 'HostedZones[?Name==`matchacake.click.`].Id' --output text

# Terraform 적용 (route53_zone_id 변수 필요)
terraform init
terraform apply -var="route53_zone_id=<YOUR_ZONE_ID>"
```

## 2. 리소스 확인

### Terraform Output 확인
```bash
cd /root/Terraform/domain-access-logs
terraform output
```

출력 정보:
- `opensearch_endpoint`: OpenSearch 엔드포인트
- `opensearch_dashboard_url`: OpenSearch 대시보드 URL
- `lambda_function_name`: Lambda 함수 이름
- `cloudwatch_log_group_arn`: CloudWatch Log Group ARN

## 3. 테스트 방법

### 3.1 DNS 쿼리 생성 (테스트 트래픽 생성)

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

### 3.2 CloudWatch Logs 확인

```bash
# Log Group 확인
aws logs describe-log-groups --log-group-name-prefix "/aws/route53/y2om-query-logs" --query 'logGroups[0]'

# 로그 스트림 확인
LOG_GROUP_NAME="/aws/route53/y2om-query-logs"
aws logs describe-log-streams --log-group-name "$LOG_GROUP_NAME" --order-by LastEventTime --descending --max-items 5

# 최근 로그 이벤트 확인
aws logs tail "$LOG_GROUP_NAME" --follow --format short
```

### 3.3 Lambda 함수 확인

```bash
# Lambda 함수 상태 확인
aws lambda get-function --function-name y2om-route53-dns-log-processor --query 'Configuration.{FunctionName:FunctionName,State:State,LastModified:LastModified}'

# Lambda 로그 확인 (Lambda 실행 로그)
aws logs tail /aws/lambda/y2om-route53-dns-log-processor --follow --format short

# Lambda 함수 수동 테스트 (선택사항)
aws lambda invoke --function-name y2om-route53-dns-log-processor --payload '{"test":"data"}' response.json
cat response.json
```

### 3.4 OpenSearch 대시보드 접근

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

### 3.5 AWS 콘솔에서 확인

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

## 4. 데이터 검증

### OpenSearch 쿼리 예시

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

## 5. 문제 해결

### 로그가 생성되지 않는 경우
- Route53 Query Logging이 활성화되었는지 확인
- CloudWatch Log Resource Policy가 올바르게 설정되었는지 확인
- DNS 쿼리가 실제로 발생했는지 확인

### Lambda가 실행되지 않는 경우
- CloudWatch Logs Subscription Filter가 올바르게 설정되었는지 확인
- Lambda 권한 (lambda_permission) 확인
- Lambda 함수 로그에서 오류 확인

### OpenSearch에 데이터가 없는 경우
- Lambda 함수 로그 확인
- OpenSearch 인덱스가 생성되었는지 확인
- Lambda IAM 역할에 OpenSearch 접근 권한 확인
- OpenSearch 도메인 상태 확인 (활성화되어 있는지)

## 6. 모니터링

### CloudWatch 메트릭 확인
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

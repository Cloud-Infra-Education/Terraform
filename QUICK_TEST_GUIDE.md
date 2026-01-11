# 빠른 테스트 가이드

## Domain Access Logs 적용 및 테스트

### 1. Domain Access Logs 적용 (빠른 방법)

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

### 2. 적용 후 Output 확인

```bash
cd /root/Terraform/domain-access-logs
terraform output
```

중요 정보:
- `opensearch_dashboard_url`: OpenSearch 대시보드 URL
- `lambda_function_name`: Lambda 함수 이름

### 3. 간단한 테스트 (5분 내)

#### Step 1: DNS 쿼리 생성
```bash
# DNS 쿼리를 여러 번 실행하여 로그 생성
for i in {1..20}; do 
  dig matchacake.click +short
  sleep 2
done
```

#### Step 2: CloudWatch Logs 확인
```bash
# 로그가 생성되었는지 확인 (약 1-2분 후)
aws logs tail /aws/route53/y2om-query-logs --since 5m --format short
```

#### Step 3: Lambda 실행 확인
```bash
# Lambda 함수가 실행되었는지 확인
aws logs tail /aws/lambda/y2om-route53-dns-log-processor --since 5m --format short
```

#### Step 4: OpenSearch 데이터 확인 (AWS CLI)
```bash
# OpenSearch 엔드포인트 확인
cd /root/Terraform/domain-access-logs
OPENSEARCH_ENDPOINT=$(terraform output -raw opensearch_endpoint)
echo "OpenSearch Endpoint: $OPENSEARCH_ENDPOINT"

# 인덱스 확인 (IAM 인증 필요 - EC2에서 실행하거나 AWS CLI 자격증명 설정 필요)
# curl -X GET "https://$OPENSEARCH_ENDPOINT/_cat/indices/y2om-route53-dns-logs?v" \
#   --aws-sigv4 "aws:amz:us-east-1:es"
```

### 4. AWS 콘솔에서 확인

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

### 5. 전체 인프라 적용 (선택사항)

전체 인프라를 적용하려면:

```bash
cd /root/Terraform
./scripts/terraform-apply.sh
```

⚠️ **주의**: 전체 인프라 적용은 시간이 오래 걸릴 수 있습니다 (30분~1시간).

---

자세한 테스트 가이드는 `domain-access-logs-test-guide.md`를 참조하세요.

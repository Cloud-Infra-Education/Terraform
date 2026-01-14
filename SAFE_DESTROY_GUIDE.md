# 안전한 인프라 Destroy 가이드

## ⚠️ Destroy 전 확인 사항

### 1. 중요한 데이터 백업

#### DB 데이터 (필요 시)
```bash
# RDS 데이터 백업 (필요한 경우)
mysqldump -h <rds-proxy-endpoint> -u admin -p ott_db > backup.sql
```

#### S3 버킷 데이터
```bash
# S3 버킷 확인
aws s3 ls s3://formation-lap-yuh-origin-bucket/

# 중요한 비디오 파일이 있다면 백업
aws s3 sync s3://formation-lap-yuh-origin-bucket/ ./s3-backup/
```

### 2. Terraform State 파일 확인

State 파일이 있으면 destroy 후에도 나중에 다시 배포 가능:
```bash
# State 파일 위치 확인
cd /root/Terraform
find . -name "*.tfstate" -o -name ".terraform.lock.hcl"
```

### 3. ECR 이미지 (유지 권장)

ECR 이미지는 비용이 거의 없으므로 유지하는 것을 권장:
- Lambda 이미지가 ECR에 저장되어 있음
- 나중에 다시 배포할 때 빠름

## Destroy 순서

### 순서대로 실행 (중요!)

Terraform 스택은 의존성이 있으므로 역순으로 destroy:

```bash
# 1. 10-app-monitoring (가장 나중에 만든 것)
cd /root/Terraform/10-app-monitoring
terraform destroy

# 2. 08-domain-ga
cd /root/Terraform/08-domain-ga
terraform destroy

# 3. 07-domain-cf
cd /root/Terraform/07-domain-cf
terraform destroy

# 4. 06-certificate
cd /root/Terraform/06-certificate
terraform destroy

# 5. 05-argocd
cd /root/Terraform/05-argocd
terraform destroy

# 6. 04-addons
cd /root/Terraform/04-addons
terraform destroy

# 7. 03-database (Lambda, RDS, RDS Proxy)
cd /root/Terraform/03-database
terraform destroy

# 8. 02-kubernetes (EKS, ECR)
cd /root/Terraform/02-kubernetes
terraform destroy

# 9. 01-infra (VPC, S3, Network)
cd /root/Terraform/01-infra
terraform destroy
```

### 또는 스크립트 사용

```bash
cd /root/Terraform
./scripts/terraform-destroy.sh
```

## ⚠️ 주의사항

### 1. S3 버킷 비우기

S3 버킷이 비어있지 않으면 destroy 실패:
```bash
# S3 버킷 비우기
aws s3 rm s3://formation-lap-yuh-origin-bucket/ --recursive
```

### 2. Lambda ENI 삭제 대기

Lambda가 VPC에 있으면 ENI(Elastic Network Interface)가 생성됨.
destroy 전에 ENI가 삭제될 때까지 대기 필요 (최대 5분)

### 3. ECR 이미지 (선택)

ECR 이미지는 유지하는 것을 권장 (비용 거의 없음)
삭제하려면:
```bash
aws ecr list-images --repository-name yuh-video-processor --region ap-northeast-2
aws ecr batch-delete-image --repository-name yuh-video-processor --image-ids ...
```

## Destroy 후

### 1. State 파일 보관 (권장)

State 파일을 백업해두면 나중에 다시 배포할 때 유용:
```bash
# State 파일 백업
tar -czf terraform-state-backup-$(date +%Y%m%d).tar.gz /root/Terraform/*/terraform.tfstate
```

### 2. 코드는 그대로 유지

- Lambda 코드: `/root/Backend/lambda/video-processor/`
- FastAPI 코드: `/root/Backend/app/video-service/`
- Terraform 코드: `/root/Terraform/`

모두 유지하면 나중에 다시 배포 가능

## 다시 배포할 때

```bash
# 1. Terraform 순서대로 apply
cd /root/Terraform/01-infra && terraform apply
cd /root/Terraform/02-kubernetes && terraform apply
cd /root/Terraform/03-database && terraform apply
# ...

# 2. Lambda 이미지 재배포 (ECR에 이미 있으면 그대로 사용)
cd /root/Backend/lambda/video-processor
bash PUSH_IMAGE.sh

# 3. FastAPI 배포 (Kubernetes)
kubectl apply -f /root/Manifests/...
```

## 결론

**✅ Destroy 해도 됩니다!**

**조건:**
1. ✅ 중요한 데이터 백업 (필요한 경우)
2. ✅ S3 버킷 비우기
3. ✅ 역순으로 destroy (의존성 고려)
4. ✅ 코드는 그대로 유지 (나중에 재배포용)

**권장:**
- ECR 이미지는 유지 (비용 거의 없음)
- State 파일 백업 (선택사항)

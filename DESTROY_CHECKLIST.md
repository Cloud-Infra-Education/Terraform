# 인프라 Destroy 체크리스트

## ✅ Destroy 해도 되는 조건

### 1. 코드 작업 완료 ✅
- [x] Lambda 코드 완성
- [x] FastAPI 코드 완성
- [x] Lambda 이미지 재배포 완료
- [x] 문서 작성 완료

### 2. 데이터 확인
- [ ] S3 버킷에 중요한 데이터 있는지 확인
- [ ] DB에 중요한 데이터 있는지 확인 (필요 시 백업)

### 3. State 파일
- [x] Terraform state 파일 존재 (나중에 재배포 가능)

## Destroy 전 확인

### S3 버킷
```bash
# 버킷 내용 확인
aws s3 ls s3://formation-lap-yuh-origin-bucket/ --recursive

# 비어있지 않으면 destroy 전에 비워야 함
aws s3 rm s3://formation-lap-yuh-origin-bucket/ --recursive
```

### DB 데이터 (선택사항)
```bash
# 중요한 데이터가 있다면 백업
mysqldump -h <rds-proxy-endpoint> -u admin -p ott_db > backup.sql
```

## Destroy 실행

### 방법 1: 스크립트 사용 (권장)

```bash
cd /root/Terraform
./scripts/terraform-destroy.sh
```

이 스크립트가:
- 역순으로 destroy (의존성 고려)
- 특수 리소스 처리 (Lambda ENI, Helm releases 등)
- 자동으로 진행

### 방법 2: 수동으로 하나씩

```bash
# 역순으로 실행
cd /root/Terraform/10-app-monitoring && terraform destroy
cd /root/Terraform/08-domain-ga && terraform destroy
cd /root/Terraform/07-domain-cf && terraform destroy
cd /root/Terraform/06-certificate && terraform destroy
cd /root/Terraform/05-argocd && terraform destroy
cd /root/Terraform/04-addons && terraform destroy
cd /root/Terraform/03-database && terraform destroy
cd /root/Terraform/02-kubernetes && terraform destroy
cd /root/Terraform/01-infra && terraform destroy
```

## Destroy 후

### 유지되는 것들
- ✅ 코드 파일들 (Lambda, FastAPI, Terraform)
- ✅ ECR 이미지 (비용 거의 없음, 유지 권장)
- ✅ Terraform state 파일 (백업 권장)

### 삭제되는 것들
- ❌ VPC, 서브넷, NAT Gateway
- ❌ EKS 클러스터
- ❌ RDS, RDS Proxy
- ❌ Lambda 함수
- ❌ S3 버킷 (비어있어야 함)
- ❌ 기타 모든 인프라 리소스

## 다시 배포할 때

```bash
# 1. Terraform 순서대로 apply
cd /root/Terraform/01-infra && terraform apply
cd /root/Terraform/02-kubernetes && terraform apply
cd /root/Terraform/03-database && terraform apply
# ...

# 2. Lambda 이미지 재배포 (ECR에 있으면 빠름)
cd /root/Backend/lambda/video-processor
bash PUSH_IMAGE.sh

# 3. FastAPI 배포
kubectl apply -f /root/Manifests/...
```

## 결론

**✅ Destroy 해도 됩니다!**

**조건:**
1. ✅ 코드 작업 완료
2. ⚠️ S3 버킷 비우기 (필요 시)
3. ⚠️ DB 데이터 백업 (필요 시)

**권장:**
- State 파일 백업 (선택사항)
- ECR 이미지 유지 (비용 거의 없음)

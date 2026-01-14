# 인프라 Destroy 준비 완료

## ✅ Destroy 해도 됩니다!

### 현재 상태
- ✅ 코드 작업 완료
- ✅ Lambda 이미지 재배포 완료
- ✅ 문서 작성 완료
- ✅ S3 버킷 확인 가능

## Destroy 전 확인

### S3 버킷
버킷명: `yuh-team-formation-lap-origin-s3`

**파일이 있다면:**
```bash
# 확인
aws s3 ls s3://yuh-team-formation-lap-origin-s3/ --recursive

# 비우기 (필요 시)
aws s3 rm s3://yuh-team-formation-lap-origin-s3/ --recursive
```

**주의:** S3 버킷이 비어있지 않으면 destroy 실패할 수 있습니다.

## Destroy 실행 방법

### 방법 1: 스크립트 사용 (권장) ⭐

```bash
cd /root/Terraform
./scripts/terraform-destroy.sh
```

또는

```bash
cd /root/Terraform
./QUICK_DESTROY.sh
```

### 방법 2: 수동으로

```bash
cd /root/Terraform

# 역순으로 실행
cd 10-app-monitoring && terraform destroy -auto-approve
cd ../08-domain-ga && terraform destroy -auto-approve
cd ../07-domain-cf && terraform destroy -auto-approve
cd ../06-certificate && terraform destroy -auto-approve
cd ../05-argocd && terraform destroy -auto-approve
cd ../04-addons && terraform destroy -auto-approve
cd ../03-database && terraform destroy -auto-approve
cd ../02-kubernetes && terraform destroy -auto-approve
cd ../01-infra && terraform destroy -auto-approve
```

## Destroy 후 유지되는 것

### ✅ 코드 파일들
- `/root/Backend/lambda/video-processor/` - Lambda 코드
- `/root/Backend/app/video-service/` - FastAPI 코드
- `/root/Terraform/` - Terraform 코드
- 모든 문서 및 가이드

### ✅ ECR 이미지 (권장: 유지)
- 비용이 거의 없음
- 나중에 재배포 시 빠름
- 삭제하지 않아도 됨

### ✅ Terraform State 파일
- 나중에 재배포 시 참고 가능
- 백업 권장 (선택사항)

## 다시 배포할 때

```bash
# 1. Terraform 순서대로 apply
cd /root/Terraform/01-infra && terraform apply
cd /root/Terraform/02-kubernetes && terraform apply
cd /root/Terraform/03-database && terraform apply
# ...

# 2. Lambda 이미지 재배포
cd /root/Backend/lambda/video-processor
bash PUSH_IMAGE.sh

# 3. FastAPI 배포
kubectl apply -f /root/Manifests/...
```

## 결론

**✅ Destroy 해도 됩니다!**

**조건:**
1. ✅ 코드 작업 완료
2. ⚠️ S3 버킷 비우기 (파일이 있다면)
3. ✅ State 파일은 유지 (재배포용)

**실행:**
```bash
cd /root/Terraform
./scripts/terraform-destroy.sh
```

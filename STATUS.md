# Terraform Apply 상태

## 현재 상태 (2026-01-11)

### ✅ 완료된 리소스
- VPC, Subnets, Route Tables (KOR, USA)
- Transit Gateway 및 Peering
- VPN 연결
- S3 버킷
- ECR 리포지토리
- RDS 클러스터 및 Proxy
- EKS 클러스터 (Seoul, Oregon)
- EKS 노드 그룹

### ⏳ 진행 중
- EKS 클러스터 활성화 (Kubernetes API 서버 준비 중)
- Helm releases (Cluster Autoscaler, ArgoCD) - 클러스터 활성화 대기 중

### 📝 다음 단계

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

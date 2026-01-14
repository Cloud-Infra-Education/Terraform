# 02-kubernetes 없이 Bastion 설정하기

## 현재 상황
- 02-kubernetes가 아직 apply 안 됨
- 03-database는 `try()`로 kubernetes 없이도 동작 가능
- 01-infra는 `lambda_sg_id_kor = null`로 설정 (순환 참조 방지)

## 설정 순서

### 1. 01-infra Apply (Bastion output 생성)
```bash
cd /root/Terraform/01-infra
terraform apply
```

확인:
```bash
terraform output kor_bastion_private_ip
# 예: 10.33.1.74
```

### 2. 03-database Apply (Lambda SG 생성)
```bash
cd /root/Terraform/03-database
terraform apply
```

확인:
```bash
terraform output lambda_sg_id
# 예: sg-080b3d0a25eb4e41f
```

### 3. 01-infra 재적용 (Lambda SG ID 반영 - 선택사항)
또는 Security Group 규칙을 수동으로 추가:

```bash
cd /root/Terraform/scripts
LAMBDA_SG_ID=$(cd ../03-database && terraform output -raw lambda_sg_id)
./update-bastion-sg.sh $LAMBDA_SG_ID
```

### 4. Bastion에 HAProxy 설치
```bash
cd /root/Terraform/scripts
BASTION_IP=$(cd ../01-infra && terraform output -raw kor_bastion_private_ip)
RDS_PROXY=$(cd ../03-database && terraform output -raw proxy_endpoint)

./setup-bastion-proxy.sh $BASTION_IP $RDS_PROXY
```

## 중요 사항

### 01-infra의 lambda_sg_id_kor가 null인 이유
- 03-database에서 Lambda SG를 생성하므로 순환 참조 방지
- 01-infra apply 시 Bastion Security Group 규칙이 추가되지 않음
- 03-database apply 후 `update-bastion-sg.sh` 스크립트로 수동 추가 필요

### 02-kubernetes가 나중에 apply되면?
- 03-database는 `try()`로 처리되어 있어서 자동으로 EKS Worker SG 규칙이 추가됨
- 추가 작업 불필요

## 현재 연결 흐름

```
Lambda (Private Subnet)
  ↓
Bastion (Public Subnet) - HAProxy 필요
  ↓
RDS Proxy (Private Subnet)
  ↓
Aurora MySQL
```

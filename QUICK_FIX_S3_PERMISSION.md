# S3 권한 문제 해결 방법

## 문제
Bastion에서 S3 다운로드 시 403 Forbidden 오류 발생

## 해결 방법

### 방법 1: IAM 역할에 S3 권한 추가 (권장) ⭐

Terraform 파일이 이미 수정되었습니다. 적용하세요:

```bash
cd /root/Terraform/01-infra
terraform init -upgrade
terraform plan -var-file="../terraform.tfvars"
terraform apply -var-file="../terraform.tfvars" -auto-approve
```

또는 스크립트 실행:

```bash
cd /root/Terraform
chmod +x apply_s3_permission.sh
./apply_s3_permission.sh
```

**적용 후:**
- 인스턴스 재시작 (선택사항, 권한은 즉시 적용됨)
- 다시 코드 전송 시도: `python3 transfer_via_s3.py`

### 방법 2: SSM을 통해 직접 파일 전송 (S3 권한 불필요)

S3 권한 없이도 작동하는 방법:

```bash
cd /root/Terraform
python3 transfer_backend_direct.py
```

이 스크립트는 파일을 읽어서 SSM 명령어로 직접 생성합니다.

### 방법 3: 수동으로 S3 권한 추가 (AWS CLI)

```bash
# IAM 역할에 인라인 정책 추가
aws iam put-role-policy \
  --role-name y2om-KOR-Primary-VPC-bastion-ssm-role \
  --policy-name bastion-s3-read \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:ListBucket"],
      "Resource": [
        "arn:aws:s3:::y2om-my-origin-bucket-123456",
        "arn:aws:s3:::y2om-my-origin-bucket-123456/*"
      ]
    }]
  }' \
  --region ap-northeast-2
```

## 권장 순서

1. **방법 1 실행** (Terraform으로 S3 권한 추가)
2. **인스턴스 재시작** (선택사항)
3. **다시 코드 전송**: `python3 transfer_via_s3.py`

또는

1. **방법 2 실행** (SSM 직접 전송, S3 권한 불필요)

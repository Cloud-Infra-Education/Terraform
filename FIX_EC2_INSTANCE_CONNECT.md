# EC2 Instance Connect 실패 해결 방법

## 문제 상황
EC2 Instance Connect에서 "Failed to connect to your instance" 오류 발생

## 원인 분석

EC2 Instance Connect가 작동하려면:
1. ✅ SSM Agent 설치 (Amazon Linux 2023에는 기본 설치됨)
2. ❌ IAM 역할 필요 (SSM 접근 권한)
3. ⚠️ 보안 그룹 확인 (현재 IP가 허용되어 있는지)

현재 보안 그룹 설정:
- SSH 포트 22는 `admin_cidr` (175.192.170.212/32)에서만 허용
- 현재 접속 IP가 다를 수 있음

## 해결 방법

### 방법 1: 현재 IP를 보안 그룹에 추가 (빠른 해결) ⭐

```bash
# 현재 IP 확인
CURRENT_IP=$(curl -s https://checkip.amazonaws.com)
echo "현재 IP: $CURRENT_IP"

# 보안 그룹 ID 확인
SG_ID=$(aws ec2 describe-instances \
  --region ap-northeast-2 \
  --instance-ids i-0088889a043f54312 \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
  --output text)

# 보안 그룹에 현재 IP 추가
aws ec2 authorize-security-group-ingress \
  --region ap-northeast-2 \
  --group-id $SG_ID \
  --protocol tcp \
  --port 22 \
  --cidr $CURRENT_IP/32 \
  --description "Temporary access for EC2 Instance Connect"
```

또는 스크립트 실행:
```bash
cd /root/Terraform
chmod +x fix_bastion_sg.sh
./fix_bastion_sg.sh
```

### 방법 2: IAM 역할 추가 (EC2 Instance Connect용) ⭐⭐

EC2 Instance Connect는 SSM을 통해 작동하므로 IAM 역할이 필요합니다.

#### 2.1 Terraform 파일 생성 완료

다음 파일들이 생성되었습니다:
- `/root/Terraform/modules/vpc/bastion_iam.tf` - IAM 역할 및 인스턴스 프로필
- `/root/Terraform/modules/vpc/bastion.tf` - IAM 인스턴스 프로필 연결

#### 2.2 Terraform 적용

```bash
cd /root/Terraform/01-infra
terraform init
terraform plan -var-file="../terraform.tfvars"
terraform apply -var-file="../terraform.tfvars"
```

**주의**: 기존 인스턴스에 IAM 역할을 추가하려면 인스턴스를 재시작해야 할 수 있습니다.

### 방법 3: 보안 그룹을 더 넓게 설정 (개발 환경용)

Terraform에서 보안 그룹을 수정:

```hcl
# modules/vpc/bastion.tf
resource "aws_security_group" "bastion" {
  vpc_id = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
    # 추가: 현재 IP 또는 더 넓은 범위
    # cidr_blocks = ["0.0.0.0/0"]  # 개발 환경용 (주의!)
  }
  # ...
}
```

## 권장 해결 순서

### 즉시 해결 (방법 1)
1. 현재 IP 확인
2. 보안 그룹에 현재 IP 추가
3. EC2 Instance Connect 다시 시도

### 장기 해결 (방법 2)
1. IAM 역할 추가 (Terraform)
2. Terraform apply
3. 인스턴스 재시작 (필요시)
4. EC2 Instance Connect 사용

## 확인 명령어

### 보안 그룹 규칙 확인
```bash
aws ec2 describe-instances \
  --region ap-northeast-2 \
  --instance-ids i-0088889a043f54312 \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
  --output text | xargs -I {} aws ec2 describe-security-groups \
  --region ap-northeast-2 \
  --group-ids {} \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`22`]' \
  --output table
```

### IAM 역할 확인
```bash
aws ec2 describe-instances \
  --region ap-northeast-2 \
  --instance-ids i-0088889a043f54312 \
  --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' \
  --output text
```

### SSM Agent 상태 확인 (인스턴스 내부)
```bash
# 인스턴스에 접속 후
sudo systemctl status amazon-ssm-agent
```

## 다음 단계

1. ✅ 현재 IP 확인 및 보안 그룹에 추가
2. ✅ EC2 Instance Connect 다시 시도
3. ⏭️ IAM 역할 추가 (Terraform)
4. ⏭️ Terraform apply

## 참고

- EC2 Instance Connect는 SSM을 통해 작동하므로 IAM 역할이 필요합니다
- 보안 그룹의 SSH 규칙도 확인해야 합니다
- 현재 IP가 `admin_cidr` (175.192.170.212/32)와 다를 수 있습니다

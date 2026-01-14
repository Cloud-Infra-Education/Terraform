# EC2 Instance Connect - IAM 역할 추가 가이드

## 현재 상황

✅ **보안 그룹**: 정상 (현재 IP 175.192.170.212/32 허용됨)
❌ **IAM 역할**: 없음 (EC2 Instance Connect를 위해 필요)

## 문제 원인

EC2 Instance Connect는 AWS Systems Manager (SSM)를 통해 작동합니다.
SSM을 사용하려면 인스턴스에 IAM 역할이 필요합니다.

## 해결 방법

### 방법 1: Terraform으로 IAM 역할 추가 (권장) ⭐

#### 1.1 Terraform 파일 확인

다음 파일들이 생성되었습니다:
- `/root/Terraform/modules/vpc/bastion_iam.tf` - IAM 역할 정의
- `/root/Terraform/modules/vpc/bastion.tf` - IAM 인스턴스 프로필 연결

#### 1.2 Terraform 적용

```bash
cd /root/Terraform/01-infra
terraform init -upgrade
terraform plan -var-file="../terraform.tfvars"
terraform apply -var-file="../terraform.tfvars"
```

또는 스크립트 실행:

```bash
cd /root/Terraform
chmod +x apply_bastion_iam.sh
./apply_bastion_iam.sh
```

#### 1.3 인스턴스 재시작 (필요시)

기존 인스턴스에 IAM 역할을 추가한 경우, 인스턴스를 재시작해야 할 수 있습니다:

```bash
aws ec2 reboot-instances \
  --instance-ids i-0088889a043f54312 \
  --region ap-northeast-2
```

### 방법 2: AWS CLI로 직접 IAM 역할 추가

#### 2.1 IAM 역할 생성

```bash
# IAM 역할 생성
aws iam create-role \
  --role-name y2om-kor-bastion-ssm-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": {"Service": "ec2.amazonaws.com"},
      "Action": "sts:AssumeRole"
    }]
  }' \
  --region ap-northeast-2

# SSM 정책 연결
aws iam attach-role-policy \
  --role-name y2om-kor-bastion-ssm-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore \
  --region ap-northeast-2

# 인스턴스 프로필 생성
aws iam create-instance-profile \
  --instance-profile-name y2om-kor-bastion-ssm-profile \
  --region ap-northeast-2

# 인스턴스 프로필에 역할 추가
aws iam add-role-to-instance-profile \
  --instance-profile-name y2om-kor-bastion-ssm-profile \
  --role-name y2om-kor-bastion-ssm-role \
  --region ap-northeast-2
```

#### 2.2 인스턴스에 IAM 역할 연결

```bash
# 인스턴스에 IAM 인스턴스 프로필 연결
aws ec2 associate-iam-instance-profile \
  --instance-id i-0088889a043f54312 \
  --iam-instance-profile Name=y2om-kor-bastion-ssm-profile \
  --region ap-northeast-2
```

#### 2.3 인스턴스 재시작

```bash
aws ec2 reboot-instances \
  --instance-ids i-0088889a043f54312 \
  --region ap-northeast-2
```

## 확인 방법

### IAM 역할 확인

```bash
aws ec2 describe-instances \
  --region ap-northeast-2 \
  --instance-ids i-0088889a043f54312 \
  --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' \
  --output text
```

### SSM Agent 상태 확인 (인스턴스 내부)

인스턴스에 접속 후:

```bash
sudo systemctl status amazon-ssm-agent
sudo systemctl start amazon-ssm-agent  # 실행 중이 아니면 시작
```

## 권장 순서

1. ✅ **Terraform으로 IAM 역할 추가** (방법 1)
2. ✅ **Terraform apply 실행**
3. ✅ **인스턴스 재시작** (필요시)
4. ✅ **EC2 Instance Connect 다시 시도**

## 주의사항

- 기존 인스턴스에 IAM 역할을 추가한 경우, 인스턴스를 재시작해야 SSM Agent가 IAM 역할을 인식합니다.
- IAM 역할이 추가되면 EC2 Instance Connect가 정상적으로 작동합니다.
- 보안 그룹은 이미 올바르게 설정되어 있습니다.

## 다음 단계

1. Terraform apply 실행
2. 인스턴스 재시작
3. EC2 Instance Connect 다시 시도
4. 접속 성공 후 Backend 설정 및 실행

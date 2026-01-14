# SSH 키 없이 Bastion 접속하는 방법

## 문제 상황
SSH 키 파일(`~/.ssh/KeyPair-Seoul.pem`, `~/.ssh/KeyPair-Oregon.pem`)이 없어서 접속이 불가능합니다.

## 해결 방법

### 방법 1: AWS Systems Manager Session Manager (권장) ⭐

SSH 키 없이 AWS CLI를 통해 직접 접속할 수 있습니다.

#### 1.1 Bastion Instance ID 확인

```bash
cd /root/Terraform/01-infra

# KOR Bastion Instance ID 확인
aws ec2 describe-instances \
  --region ap-northeast-2 \
  --filters "Name=tag:Name,Values=*bastion*" "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table

# USA Bastion Instance ID 확인
aws ec2 describe-instances \
  --region us-west-2 \
  --filters "Name=tag:Name,Values=*bastion*" "Name=instance-state-name,Values=running" \
  --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

#### 1.2 SSM Agent 확인 및 설치

Bastion 인스턴스에 SSM Agent가 설치되어 있어야 합니다. Amazon Linux 2023에는 기본적으로 설치되어 있습니다.

#### 1.3 IAM 역할 확인

Bastion 인스턴스에 SSM 접근을 위한 IAM 역할이 필요합니다. 없으면 추가해야 합니다.

#### 1.4 Session Manager로 접속

```bash
# KOR Bastion 접속
aws ssm start-session \
  --target <KOR_INSTANCE_ID> \
  --region ap-northeast-2

# USA Bastion 접속
aws ssm start-session \
  --target <USA_INSTANCE_ID> \
  --region us-west-2
```

### 방법 2: EC2 Instance Connect (브라우저 접속)

AWS 콘솔에서 EC2 Instance Connect를 사용하여 브라우저에서 직접 접속할 수 있습니다.

1. AWS 콘솔 → EC2 → Instances
2. Bastion 인스턴스 선택
3. "Connect" 버튼 클릭
4. "EC2 Instance Connect" 탭 선택
5. "Connect" 버튼 클릭

### 방법 3: 기존 SSH 키 파일 찾기

다음 위치에서 키 파일을 찾아보세요:

```bash
# 일반적인 위치 확인
ls -la ~/.ssh/
ls -la ~/Downloads/*.pem
ls -la ~/Desktop/*.pem
ls -la ~/Documents/*.pem

# 전체 검색
find ~ -name "*.pem" 2>/dev/null
find ~ -name "*KeyPair*" 2>/dev/null
```

### 방법 4: 새 키 페어 생성 (주의 필요)

⚠️ **주의**: 새 키 페어를 생성하면 기존 인스턴스에는 사용할 수 없습니다. 인스턴스를 재생성하거나 키를 교체해야 합니다.

```bash
# 새 키 페어 생성
aws ec2 create-key-pair \
  --key-name KeyPair-Seoul-new \
  --region ap-northeast-2 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/KeyPair-Seoul-new.pem

# 권한 설정
chmod 400 ~/.ssh/KeyPair-Seoul-new.pem
```

## 권장 해결책

**가장 빠른 방법**: **AWS Systems Manager Session Manager** 사용

1. Bastion Instance ID 확인
2. IAM 역할이 SSM 접근 권한이 있는지 확인
3. `aws ssm start-session --target <instance-id>` 실행

## IAM 역할 추가가 필요한 경우

Bastion 인스턴스에 SSM 접근을 위한 IAM 역할을 추가해야 합니다:

```hcl
# modules/vpc/bastion.tf에 추가
resource "aws_iam_instance_profile" "bastion_ssm" {
  name = "${var.name}-bastion-ssm-profile"
  role = aws_iam_role.bastion_ssm.name
}

resource "aws_iam_role" "bastion_ssm" {
  name = "${var.name}-bastion-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "bastion_ssm" {
  role       = aws_iam_role.bastion_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# aws_instance.bastion에 추가
resource "aws_instance" "bastion" {
  # ... 기존 설정 ...
  iam_instance_profile = aws_iam_instance_profile.bastion_ssm.name
}
```

## 다음 단계

1. **즉시 해결**: EC2 Instance Connect를 사용하여 브라우저에서 접속
2. **장기 해결**: SSM을 위한 IAM 역할 추가 후 Session Manager 사용

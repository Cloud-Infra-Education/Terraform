# SSH 접속 문제 해결 가이드

## 문제: Permission denied (publickey)

SSH 접속 시 "Permission denied (publickey)" 오류가 발생하는 경우 해결 방법입니다.

## 1. 키 파일 권한 확인 및 수정

```bash
# 키 파일 권한 확인
ls -la /root/KeyPair-Seoul.pem

# 권한 수정 (400 또는 600)
chmod 400 /root/KeyPair-Seoul.pem

# 다시 접속 시도
ssh -i /root/KeyPair-Seoul.pem ec2-user@35.92.218.177
```

## 2. 키 파일과 인스턴스 키 페어 매칭 확인

### 2.1 인스턴스에 연결된 키 페어 확인

```bash
# KOR Bastion 인스턴스 키 페어 확인
aws ec2 describe-instances \
  --region ap-northeast-2 \
  --filters "Name=ip-address,Values=35.92.218.177" \
  --query 'Reservations[0].Instances[0].[KeyName,InstanceId]' \
  --output table

# USA Bastion 인스턴스 키 페어 확인
aws ec2 describe-instances \
  --region us-west-2 \
  --filters "Name=ip-address,Values=43.202.0.201" \
  --query 'Reservations[0].Instances[0].[KeyName,InstanceId]' \
  --output table
```

### 2.2 AWS 키 페어 목록 확인

```bash
# Seoul 리전 키 페어
aws ec2 describe-key-pairs --region ap-northeast-2 --output table

# Oregon 리전 키 페어
aws ec2 describe-key-pairs --region us-west-2 --output table
```

### 2.3 키 파일 이름과 인스턴스 키 이름 비교

Terraform 설정에서:
- `key_name_kor = "KeyPair-Seoul"` (terraform.tfvars)
- 실제 인스턴스에는 `y2om-KeyPair-Seoul` 형식으로 생성될 수 있음

## 3. SSH 접속 디버깅

```bash
# Verbose 모드로 접속 시도 (상세한 오류 정보 확인)
ssh -v -i /root/KeyPair-Seoul.pem ec2-user@35.92.218.177

# 더 상세한 정보
ssh -vvv -i /root/KeyPair-Seoul.pem ec2-user@35.92.218.177
```

## 4. 키 파일 형식 확인

```bash
# 키 파일 첫 줄 확인
head -1 /root/KeyPair-Seoul.pem

# 올바른 형식: -----BEGIN RSA PRIVATE KEY----- 또는 -----BEGIN PRIVATE KEY-----
```

## 5. 대안: EC2 Instance Connect (키 불필요) ⭐

SSH 키 없이 브라우저에서 접속:

1. **AWS 콘솔 접속**
   - https://console.aws.amazon.com/ec2/

2. **EC2 → Instances**

3. **Bastion 인스턴스 찾기**
   - Public IP로 검색: `35.92.218.177` (KOR) 또는 `43.202.0.201` (USA)

4. **인스턴스 선택 → "Connect" 버튼 클릭**

5. **"EC2 Instance Connect" 탭 선택**

6. **"Connect" 버튼 클릭**

## 6. 대안: SSM Session Manager

### 6.1 Instance ID 확인

```bash
# KOR Bastion Instance ID
aws ec2 describe-instances \
  --region ap-northeast-2 \
  --filters "Name=ip-address,Values=35.92.218.177" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text

# USA Bastion Instance ID
aws ec2 describe-instances \
  --region us-west-2 \
  --filters "Name=ip-address,Values=43.202.0.201" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text
```

### 6.2 SSM 접속

```bash
# KOR Bastion
aws ssm start-session --target <INSTANCE_ID> --region ap-northeast-2

# USA Bastion
aws ssm start-session --target <INSTANCE_ID> --region us-west-2
```

**주의**: SSM을 사용하려면 인스턴스에 SSM Agent가 설치되어 있고, IAM 역할이 필요합니다.

## 7. 문제 진단 스크립트 실행

```bash
cd /root/Terraform
python3 check_ssh_key.py
```

이 스크립트는 다음을 확인합니다:
- 키 파일 존재 여부
- 키 파일 권한
- AWS 키 페어 목록
- 인스턴스에 연결된 키 페어
- 키 이름 매칭 여부

## 8. 일반적인 해결 방법 요약

### 방법 1: 키 파일 권한 수정 (가장 흔한 원인)

```bash
chmod 400 /root/KeyPair-Seoul.pem
ssh -i /root/KeyPair-Seoul.pem ec2-user@35.92.218.177
```

### 방법 2: 올바른 키 파일 사용

키 파일 이름이 인스턴스의 키 페어와 일치하는지 확인:
- 인스턴스 키: `y2om-KeyPair-Seoul` 또는 `KeyPair-Seoul`
- 키 파일: `/root/KeyPair-Seoul.pem`

### 방법 3: EC2 Instance Connect 사용 (권장)

- SSH 키 불필요
- 브라우저에서 바로 접속
- 추가 설정 불필요

### 방법 4: SSM Session Manager 설정

- IAM 역할 추가 필요
- 장기적으로 유용

## 9. 추가 확인 사항

### 보안 그룹 확인

SSH 포트(22)가 관리자 IP에서 접근 가능한지 확인:

```bash
# KOR Bastion 보안 그룹 확인
aws ec2 describe-instances \
  --region ap-northeast-2 \
  --filters "Name=ip-address,Values=35.92.218.177" \
  --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' \
  --output text

# 보안 그룹 규칙 확인
aws ec2 describe-security-groups \
  --group-ids <SECURITY_GROUP_ID> \
  --region ap-northeast-2
```

관리자 IP: `175.192.170.212/32` (terraform.tfvars의 `admin_cidr`)

## 10. 빠른 해결 체크리스트

- [ ] 키 파일 권한이 400 또는 600인가? (`chmod 400`)
- [ ] 키 파일이 비어있지 않은가? (`ls -lh`)
- [ ] 키 파일 이름이 인스턴스 키 페어와 일치하는가?
- [ ] 현재 IP가 보안 그룹의 허용 IP 범위에 있는가?
- [ ] EC2 Instance Connect로 접속 가능한가?

## 다음 단계

1. **즉시 해결**: EC2 Instance Connect 사용
2. **SSH 키 수정**: 권한 및 키 파일 확인
3. **장기 해결**: SSM Session Manager 설정

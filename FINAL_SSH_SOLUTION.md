# SSH 접속 최종 해결 방법

## 문제 진단 결과

✅ **키 파일 상태**: 정상 (권한 400, 크기 1678 bytes, RSA 형식)
❌ **SSH 인식**: 실패 (`type -1` - 키를 인식하지 못함)
⚠️ **키 이름**: 인스턴스에는 `y2om-KeyPair-Seoul`이 연결되어 있을 가능성

## 가장 빠른 해결 방법: EC2 Instance Connect ⭐⭐⭐

**SSH 키 없이 브라우저에서 바로 접속 가능합니다.**

### 단계별 가이드:

1. **AWS 콘솔 접속**
   - https://ap-northeast-2.console.aws.amazon.com/ec2/

2. **EC2 → Instances**

3. **Bastion 인스턴스 찾기**
   - 검색창에 IP 입력: `35.92.218.177`
   - 또는 태그로 검색: `*bastion*`

4. **인스턴스 선택 → "Connect" 버튼**

5. **"EC2 Instance Connect" 탭 선택**

6. **"Connect" 버튼 클릭**

7. **브라우저에서 터미널이 열립니다!**

## 문제 원인 확인 명령어

다음 명령어를 실행하여 정확한 원인을 확인하세요:

### 1. 인스턴스에 연결된 키 페어 확인

```bash
aws ec2 describe-instances \
  --region ap-northeast-2 \
  --filters "Name=ip-address,Values=35.92.218.177" \
  --query 'Reservations[0].Instances[0].[InstanceId,KeyName,Tags[?Key==`Name`].Value|[0]]' \
  --output table
```

### 2. 키 파일 형식 확인

```bash
# 키 파일 첫 줄 확인
head -1 /root/KeyPair-Seoul.pem

# 키 파일 형식 확인
file /root/KeyPair-Seoul.pem
```

### 3. 문제 해결 스크립트 실행

```bash
cd /root/Terraform
python3 fix_ssh_connection.py
```

## 해결 방법

### 방법 1: EC2 Instance Connect (권장) ⭐⭐⭐

- SSH 키 불필요
- 브라우저에서 바로 접속
- 추가 설정 불필요
- **가장 빠르고 확실한 방법**

### 방법 2: 올바른 키 파일 찾기

인스턴스에 연결된 키 페어가 `y2om-KeyPair-Seoul`인 경우:

```bash
# y2om-KeyPair-Seoul 키 파일 찾기
find /root -name "*y2om*" -o -name "*KeyPair*" 2>/dev/null

# 또는 다른 위치에서 찾기
find / -name "*y2om-KeyPair-Seoul*" 2>/dev/null
```

올바른 키 파일을 찾으면:

```bash
chmod 400 /root/y2om-KeyPair-Seoul.pem  # 예시
ssh -i /root/y2om-KeyPair-Seoul.pem ec2-user@35.92.218.177
```

### 방법 3: 키 파일 형식 변환 시도

현재 키 파일이 RSA PRIVATE KEY 형식인 경우, OpenSSH가 인식하지 못할 수 있습니다.

```bash
# 키 파일 형식 변환 (비밀번호 없이 Enter만 누르면 됨)
ssh-keygen -p -m PEM -f /root/KeyPair-Seoul.pem

# 또는 새 형식으로 변환
ssh-keygen -p -m RFC4716 -f /root/KeyPair-Seoul.pem
```

변환 후 다시 접속 시도:

```bash
ssh -i /root/KeyPair-Seoul.pem ec2-user@35.92.218.177
```

### 방법 4: SSM Session Manager

인스턴스 ID 확인 후:

```bash
# Instance ID 확인
INSTANCE_ID=$(aws ec2 describe-instances \
  --region ap-northeast-2 \
  --filters "Name=ip-address,Values=35.92.218.177" \
  --query 'Reservations[0].Instances[0].InstanceId' \
  --output text)

# SSM 접속
aws ssm start-session --target $INSTANCE_ID --region ap-northeast-2
```

**주의**: SSM을 사용하려면 인스턴스에 SSM 접근을 위한 IAM 역할이 필요합니다.

## 빠른 해결 체크리스트

- [ ] **EC2 Instance Connect 사용** (가장 빠름) ⭐
- [ ] 인스턴스에 연결된 키 페어 확인
- [ ] 올바른 키 파일 찾기
- [ ] 키 파일 형식 변환 시도
- [ ] SSM Session Manager 설정

## 권장 순서

1. **즉시 접속 필요**: EC2 Instance Connect 사용
2. **SSH 키 수정**: 인스턴스 키 페어 확인 → 올바른 키 파일 찾기
3. **장기 해결**: SSM Session Manager 설정

## 다음 단계

1. ✅ EC2 Instance Connect로 접속
2. ✅ Bastion에서 Backend 설정 및 실행
3. ⏭️ 필요시 SSH 키 문제 해결

## 참고 문서

- `/root/Terraform/SSH_TROUBLESHOOTING.md` - 상세한 문제 해결 가이드
- `/root/Terraform/BASTION_ACCESS_GUIDE.md` - Bastion 접속 및 Backend 실행 가이드
- `/root/Terraform/QUICK_FIX_SSH.md` - 빠른 해결 가이드

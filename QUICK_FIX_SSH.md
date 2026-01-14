# SSH 접속 문제 빠른 해결 방법

## 현재 상황
- 키 파일 권한: ✅ 정상 (400)
- 키 파일 존재: ✅ 확인됨
- 접속 오류: ❌ Permission denied (publickey)

## 가장 빠른 해결 방법: EC2 Instance Connect ⭐⭐⭐

**진단 결과: 키 파일은 정상이지만 SSH가 인식하지 못함 (`type -1`)**
**→ EC2 Instance Connect 사용을 강력히 권장합니다!**

**SSH 키 없이 브라우저에서 바로 접속 가능합니다.**

### 단계별 가이드:

1. **AWS 콘솔 접속**
   - https://console.aws.amazon.com/ec2/
   - 또는 https://ap-northeast-2.console.aws.amazon.com/ec2/

2. **EC2 → Instances 메뉴**

3. **Bastion 인스턴스 찾기**
   - 검색창에 IP 주소 입력: `35.92.218.177`
   - 또는 태그로 검색: `*bastion*`

4. **인스턴스 선택**

5. **"Connect" 버튼 클릭**

6. **"EC2 Instance Connect" 탭 선택**

7. **"Connect" 버튼 클릭**

8. **브라우저에서 터미널이 열립니다!**

## 문제 원인 확인 명령어

다음 명령어를 직접 실행하여 문제를 진단하세요:

### 1. 인스턴스에 연결된 키 페어 확인

```bash
aws ec2 describe-instances \
  --region ap-northeast-2 \
  --filters "Name=ip-address,Values=35.92.218.177" \
  --query 'Reservations[0].Instances[0].[KeyName,InstanceId]' \
  --output table
```

### 2. SSH 디버그 모드로 상세 오류 확인

```bash
ssh -vvv -i /root/KeyPair-Seoul.pem ec2-user@35.92.218.177 2>&1 | head -30
```

### 3. 문제 진단 스크립트 실행

```bash
cd /root/Terraform
python3 diagnose_ssh_issue.py
```

## 가능한 원인

1. **키 파일이 인스턴스에 연결된 키와 일치하지 않음**
   - Terraform에서 `key_name_kor = "KeyPair-Seoul"`로 설정
   - 실제 인스턴스에는 `y2om-KeyPair-Seoul` 형식으로 생성되었을 수 있음

2. **키 파일이 잘못된 키**
   - 다른 인스턴스용 키일 수 있음
   - 키 파일이 손상되었을 수 있음

3. **키 파일 형식 문제**
   - 올바른 PEM 형식인지 확인 필요

## 추가 해결 방법

### 방법 1: 다른 위치에서 키 파일 찾기

```bash
# 전체 시스템에서 키 파일 검색
find / -name "*.pem" 2>/dev/null | grep -i key
find / -name "*KeyPair*" 2>/dev/null
```

### 방법 2: AWS에서 키 페어 확인

```bash
# Seoul 리전 키 페어 목록
aws ec2 describe-key-pairs --region ap-northeast-2 --output table

# 키 페어 상세 정보
aws ec2 describe-key-pairs --key-names "KeyPair-Seoul" --region ap-northeast-2
```

### 방법 3: SSM Session Manager 설정

인스턴스에 SSM 접근을 위한 IAM 역할을 추가하면 키 없이 접속 가능합니다.

## 권장 사항

**지금 당장 접속해야 한다면:**
→ **EC2 Instance Connect 사용** (브라우저에서 바로 접속)

**장기적으로:**
→ SSM Session Manager 설정 (IAM 역할 추가)

## 다음 단계

1. ✅ EC2 Instance Connect로 접속
2. ✅ Bastion에서 Backend 설정 및 실행
3. ⏭️ 필요시 SSM Session Manager 설정

## 참고 문서

- `/root/Terraform/SSH_TROUBLESHOOTING.md` - 상세한 문제 해결 가이드
- `/root/Terraform/BASTION_ACCESS_GUIDE.md` - Bastion 접속 및 Backend 실행 가이드

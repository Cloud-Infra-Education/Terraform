# EC2 Instance Connect 여전히 작동하지 않는 경우 - 최종 해결 방법

## 문제 상황
IAM 역할은 연결되었지만 EC2 Instance Connect가 여전히 작동하지 않습니다.

## 가능한 원인

1. **SSM Agent가 실행되지 않음**
2. **인스턴스가 재시작되지 않아 IAM 역할이 적용되지 않음**
3. **SSM Agent가 IAM 역할을 아직 인식하지 못함**
4. **네트워크 연결 문제**

## 해결 방법

### 방법 1: SSM Agent 상태 확인 및 인스턴스 재시작 ⭐

#### 1.1 SSM Agent 상태 확인

```bash
# SSM Agent 연결 상태 확인
aws ssm describe-instance-information \
  --region ap-northeast-2 \
  --filters "Key=InstanceIds,Values=i-0088889a043f54312" \
  --query 'InstanceInformationList[0].[PingStatus,LastPingDateTime]' \
  --output table
```

**예상 결과:**
- `PingStatus: Online` → 정상
- `PingStatus: Inactive` → SSM Agent가 비활성 상태
- 결과가 없음 → SSM Agent가 등록되지 않음

#### 1.2 인스턴스 재시작

```bash
# KOR Bastion 재시작
aws ec2 reboot-instances \
  --instance-ids i-0088889a043f54312 \
  --region ap-northeast-2

# 재시작 후 2-3분 대기
```

#### 1.3 재시작 후 SSM 상태 확인

```bash
# 2-3분 후 다시 확인
aws ssm describe-instance-information \
  --region ap-northeast-2 \
  --filters "Key=InstanceIds,Values=i-0088889a043f54312" \
  --query 'InstanceInformationList[0].PingStatus' \
  --output text
```

### 방법 2: SSM Session Manager로 직접 접속 시도

EC2 Instance Connect 대신 SSM Session Manager를 사용해보세요:

```bash
aws ssm start-session \
  --target i-0088889a043f54312 \
  --region ap-northeast-2
```

**이것이 작동하면:**
- IAM 역할은 정상입니다
- SSM Agent도 정상입니다
- EC2 Instance Connect의 다른 문제일 수 있습니다

**이것이 작동하지 않으면:**
- SSM Agent 문제 또는 IAM 역할 문제입니다

### 방법 3: 인스턴스 내부에서 SSM Agent 확인 (SSH 또는 다른 방법으로 접속 가능한 경우)

만약 다른 방법으로 인스턴스에 접속할 수 있다면:

```bash
# SSM Agent 상태 확인
sudo systemctl status amazon-ssm-agent

# SSM Agent 시작
sudo systemctl start amazon-ssm-agent

# SSM Agent 자동 시작 설정
sudo systemctl enable amazon-ssm-agent

# SSM Agent 재시작
sudo systemctl restart amazon-ssm-agent
```

### 방법 4: 문제 진단 스크립트 실행

```bash
cd /root/Terraform
python3 check_ssm_agent.py
```

이 스크립트는 다음을 확인합니다:
- 인스턴스 상태
- IAM 프로필 연결 상태
- SSM Agent 연결 상태
- 해결 방법 제시

### 방법 5: 인스턴스 재시작 및 자동 확인 스크립트

```bash
cd /root/Terraform
chmod +x restart_bastion.sh
./restart_bastion.sh
```

이 스크립트는:
1. 인스턴스를 재시작합니다
2. 30초 후 SSM Agent 상태를 확인하기 시작합니다
3. 최대 2분 동안 상태를 모니터링합니다

## 단계별 해결 체크리스트

- [ ] **인스턴스 재시작** (IAM 역할 적용)
- [ ] **SSM Agent 상태 확인** (`PingStatus: Online` 확인)
- [ ] **SSM Session Manager로 접속 시도** (`aws ssm start-session`)
- [ ] **EC2 Instance Connect 다시 시도**
- [ ] **문제 지속 시**: 인스턴스 내부에서 SSM Agent 확인

## 빠른 해결 순서

1. **인스턴스 재시작**
   ```bash
   aws ec2 reboot-instances --instance-ids i-0088889a043f54312 --region ap-northeast-2
   ```

2. **2-3분 대기**

3. **SSM 상태 확인**
   ```bash
   aws ssm describe-instance-information --region ap-northeast-2 --filters "Key=InstanceIds,Values=i-0088889a043f54312" --query 'InstanceInformationList[0].PingStatus' --output text
   ```

4. **SSM Session Manager로 접속 시도**
   ```bash
   aws ssm start-session --target i-0088889a043f54312 --region ap-northeast-2
   ```

5. **작동하면 EC2 Instance Connect 다시 시도**

## 추가 확인 사항

### IAM 역할 정책 확인

```bash
# IAM 역할 확인
aws iam get-role \
  --role-name y2om-KOR-Primary-VPC-bastion-ssm-role \
  --query 'Role.AssumeRolePolicyDocument'

# 연결된 정책 확인
aws iam list-attached-role-policies \
  --role-name y2om-KOR-Primary-VPC-bastion-ssm-role
```

### 보안 그룹 확인

EC2 Instance Connect는 SSM을 통해 작동하므로 보안 그룹의 SSH 규칙이 직접 필요하지 않을 수 있지만, 확인해보세요:

```bash
aws ec2 describe-security-groups \
  --group-ids sg-0ec1c2ec995acd6c6 \
  --region ap-northeast-2 \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`22`]' \
  --output table
```

## 다음 단계

1. ✅ 인스턴스 재시작
2. ✅ SSM Agent 상태 확인
3. ✅ SSM Session Manager로 접속 시도
4. ✅ 문제 지속 시 상세 진단

## 참고

- SSM Agent는 인스턴스 시작 시 자동으로 시작됩니다
- IAM 역할이 추가된 후 인스턴스를 재시작해야 적용됩니다
- SSM Agent가 Online 상태가 되려면 몇 분이 걸릴 수 있습니다

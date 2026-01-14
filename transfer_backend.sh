#!/bin/bash
# Backend 코드를 Bastion으로 전송

BASTION_IP="43.202.0.201"  # KOR Bastion Public IP (출력에서 확인)
BASTION_USER="ec2-user"
BACKEND_DIR="/root/Backend"
SSH_KEY="/root/KeyPair-Seoul.pem"

echo "============================================================"
echo "Backend 코드를 Bastion으로 전송"
echo "============================================================"
echo ""

# SSH 키 확인
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH 키 파일을 찾을 수 없습니다: $SSH_KEY"
    echo ""
    echo "SSM Session Manager를 사용하여 수동으로 전송하거나,"
    echo "Git에서 클론하는 방법을 사용하세요."
    exit 1
fi

echo "SSH 키 확인: $SSH_KEY"
chmod 400 $SSH_KEY

echo ""
echo "Backend 코드 전송 중..."
echo "대상: $BASTION_USER@$BASTION_IP:~/Backend"
echo ""

# tar로 압축하여 전송 (더 효율적)
cd /root
tar -czf /tmp/backend.tar.gz \
  --exclude='__pycache__' \
  --exclude='*.pyc' \
  --exclude='.git' \
  --exclude='test.db' \
  --exclude='.env' \
  Backend/

# SCP로 전송
scp -i $SSH_KEY /tmp/backend.tar.gz $BASTION_USER@$BASTION_IP:/tmp/

if [ $? -eq 0 ]; then
    echo "✅ 파일 전송 완료!"
    echo ""
    echo "Bastion에서 압축 해제 중..."
    
    # SSM을 통해 압축 해제
    aws ssm send-command \
      --instance-ids i-0088889a043f54312 \
      --region ap-northeast-2 \
      --document-name "AWS-RunShellScript" \
      --parameters 'commands=[
        "cd ~/Backend",
        "tar -xzf /tmp/backend.tar.gz --strip-components=1",
        "rm /tmp/backend.tar.gz",
        "ls -la"
      ]' \
      --output text \
      --query 'Command.CommandId' > /tmp/extract_cmd_id.txt
    
    EXTRACT_CMD_ID=$(cat /tmp/extract_cmd_id.txt)
    echo "Command ID: $EXTRACT_CMD_ID"
    echo "압축 해제 중... (20초 대기)"
    sleep 20
    
    # 결과 확인
    aws ssm get-command-invocation \
      --command-id $EXTRACT_CMD_ID \
      --instance-id i-0088889a043f54312 \
      --region ap-northeast-2 \
      --query '[Status,StandardOutputContent]' \
      --output table
    
    echo ""
    echo "✅ Backend 코드 전송 및 설정 완료!"
    echo ""
    echo "다음 단계:"
    echo "1. SSM Session Manager로 Bastion 접속:"
    echo "   aws ssm start-session --target i-0088889a043f54312 --region ap-northeast-2"
    echo ""
    echo "2. 접속 후 다음 명령어 실행:"
    echo "   cd ~/Backend"
    echo "   pip3 install --user -r requirements.txt"
    echo "   python3 -m uvicorn main:app --host 0.0.0.0 --port 8000"
else
    echo ""
    echo "❌ 코드 전송 실패"
    echo ""
    echo "대안: Git에서 클론하거나 SSM Session Manager에서 수동으로 설정"
fi

# 임시 파일 정리
rm -f /tmp/backend.tar.gz /tmp/extract_cmd_id.txt

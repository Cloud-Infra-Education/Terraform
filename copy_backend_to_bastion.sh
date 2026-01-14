#!/bin/bash
# 로컬 Backend 코드를 Bastion으로 전송

BASTION_IP="43.202.0.201"  # KOR Bastion Public IP
BASTION_USER="ec2-user"
BACKEND_DIR="/root/Backend"

echo "============================================================"
echo "Backend 코드를 Bastion으로 전송"
echo "============================================================"
echo ""

# SSH 키 확인
SSH_KEY="/root/KeyPair-Seoul.pem"
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

# SCP로 코드 전송
scp -i $SSH_KEY -r $BACKEND_DIR/* $BASTION_USER@$BASTION_IP:~/Backend/

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Backend 코드 전송 완료!"
    echo ""
    echo "다음 단계:"
    echo "1. SSM Session Manager로 Bastion 접속:"
    echo "   aws ssm start-session --target i-0088889a043f54312 --region ap-northeast-2"
    echo ""
    echo "2. 접속 후 다음 명령어 실행:"
    echo "   cd ~/Backend"
    echo "   cat /root/Terraform/setup_backend_commands.txt 참고"
else
    echo ""
    echo "❌ 코드 전송 실패"
    echo ""
    echo "대안:"
    echo "1. SSM Session Manager로 접속하여 수동으로 설정"
    echo "2. Git에서 클론"
fi

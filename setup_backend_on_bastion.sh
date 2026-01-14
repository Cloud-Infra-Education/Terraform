#!/bin/bash
# Bastion 호스트에서 Backend 설정 및 실행 스크립트
# SSM Session Manager를 통해 실행

INSTANCE_ID="i-0088889a043f54312"
REGION="ap-northeast-2"

echo "============================================================"
echo "Bastion 호스트에서 Backend 설정"
echo "============================================================"
echo ""

# SSM을 통해 명령어 실행
echo "1. 시스템 업데이트 및 필요한 도구 설치..."
aws ssm send-command \
  --instance-ids $INSTANCE_ID \
  --region $REGION \
  --document-name "AWS-RunShellScript" \
  --parameters 'commands=[
    "sudo yum update -y",
    "sudo yum install -y python3 python3-pip git mysql",
    "python3 --version",
    "pip3 --version"
  ]' \
  --output text \
  --query 'Command.CommandId' > /tmp/command_id.txt

COMMAND_ID=$(cat /tmp/command_id.txt)
echo "Command ID: $COMMAND_ID"
echo "명령어 실행 중... (30초 대기)"
sleep 30

# 명령어 결과 확인
aws ssm get-command-invocation \
  --command-id $COMMAND_ID \
  --instance-id $INSTANCE_ID \
  --region $REGION \
  --query '[Status,StandardOutputContent,StandardErrorContent]' \
  --output table

echo ""
echo "2. Backend 디렉토리 생성 및 코드 준비..."
echo "   (다음 단계는 수동으로 진행해야 합니다)"
echo ""
echo "다음 명령어를 SSM Session Manager에서 실행하세요:"
echo ""
echo "aws ssm start-session --target $INSTANCE_ID --region $REGION"
echo ""
echo "접속 후 다음 명령어 실행:"
echo ""
echo "# 홈 디렉토리로 이동"
echo "cd ~"
echo ""
echo "# Backend 디렉토리 생성"
echo "mkdir -p Backend"
echo "cd Backend"
echo ""
echo "# Git에서 클론하거나, SCP로 코드 전송"
echo "# Git 클론 예시:"
echo "# git clone <your-backend-repo-url> ."
echo ""
echo "# 또는 로컬에서 SCP로 전송:"
echo "# scp -r /root/Backend/* ec2-user@<BASTION_IP>:~/Backend/"

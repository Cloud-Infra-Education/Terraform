#!/bin/bash
# Bastion 인스턴스 재시작 및 SSM 상태 확인

INSTANCE_ID="i-0088889a043f54312"
REGION="ap-northeast-2"

echo "============================================================"
echo "Bastion 인스턴스 재시작 및 SSM 상태 확인"
echo "============================================================"
echo ""

echo "1. 인스턴스 재시작..."
aws ec2 reboot-instances \
  --instance-ids $INSTANCE_ID \
  --region $REGION

if [ $? -eq 0 ]; then
    echo "✅ 재시작 명령 전송 완료"
    echo ""
    echo "인스턴스가 재시작되는 동안 2-3분 정도 기다려주세요..."
    echo ""
    
    echo "2. SSM Agent 상태 확인 (30초 후)..."
    sleep 30
    
    echo "SSM 연결 상태 확인 중..."
    for i in {1..12}; do
        PING_STATUS=$(aws ssm describe-instance-information \
          --region $REGION \
          --filters "Key=InstanceIds,Values=$INSTANCE_ID" \
          --query 'InstanceInformationList[0].PingStatus' \
          --output text 2>/dev/null)
        
        if [ "$PING_STATUS" == "Online" ]; then
            echo "✅ SSM Agent가 Online 상태입니다!"
            echo ""
            echo "이제 EC2 Instance Connect를 시도할 수 있습니다."
            break
        elif [ "$PING_STATUS" == "Inactive" ]; then
            echo "⚠️  SSM Agent가 Inactive 상태입니다. 계속 대기 중... ($i/12)"
        else
            echo "⏳ SSM Agent 상태 확인 중... ($i/12)"
        fi
        
        if [ $i -lt 12 ]; then
            sleep 10
        fi
    done
    
    if [ "$PING_STATUS" != "Online" ]; then
        echo ""
        echo "⚠️  SSM Agent가 아직 Online 상태가 아닙니다."
        echo "   몇 분 더 기다린 후 다시 확인하세요:"
        echo "   aws ssm describe-instance-information --region $REGION --filters 'Key=InstanceIds,Values=$INSTANCE_ID' --query 'InstanceInformationList[0].PingStatus' --output text"
    fi
else
    echo "❌ 재시작 명령 실패"
fi

echo ""
echo "3. SSM Session Manager로 직접 접속 시도:"
echo "   aws ssm start-session --target $INSTANCE_ID --region $REGION"

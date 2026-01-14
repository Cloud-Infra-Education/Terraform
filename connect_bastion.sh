#!/bin/bash
# Bastion 호스트 접속 스크립트

KOR_BASTION_IP="35.92.218.177"
USA_BASTION_IP="43.202.0.201"
KOR_KEY="/root/KeyPair-Seoul.pem"
USA_KEY="/root/KeyPair-Oregon.pem"

echo "============================================================"
echo "Bastion 호스트 접속"
echo "============================================================"
echo ""
echo "1. KOR (Seoul) Bastion: $KOR_BASTION_IP"
echo "2. USA (Oregon) Bastion: $USA_BASTION_IP"
echo "3. 종료"
echo ""
read -p "선택하세요 (1-3): " choice

case $choice in
    1)
        if [ -f "$KOR_KEY" ]; then
            # 키 파일 권한 확인 및 수정
            chmod 400 "$KOR_KEY" 2>/dev/null
            echo "KOR Bastion에 접속합니다..."
            echo "키 파일: $KOR_KEY"
            echo "IP: $KOR_BASTION_IP"
            echo ""
            echo "접속 실패 시:"
            echo "1. 키 파일 권한 확인: chmod 400 $KOR_KEY"
            echo "2. EC2 Instance Connect 사용 (브라우저)"
            echo "3. python3 check_ssh_key.py 실행하여 문제 진단"
            echo ""
            ssh -i "$KOR_KEY" ec2-user@$KOR_BASTION_IP
        else
            echo "❌ 오류: 키 파일을 찾을 수 없습니다: $KOR_KEY"
            echo ""
            echo "대안:"
            echo "1. EC2 Instance Connect 사용 (AWS 콘솔)"
            echo "2. SSM Session Manager 사용"
            exit 1
        fi
        ;;
    2)
        if [ -f "$USA_KEY" ]; then
            echo "USA Bastion에 접속합니다..."
            ssh -i "$USA_KEY" ec2-user@$USA_BASTION_IP
        else
            echo "❌ 오류: 키 파일을 찾을 수 없습니다: $USA_KEY"
            echo "대안: EC2 Instance Connect 또는 SSM Session Manager 사용"
            exit 1
        fi
        ;;
    3)
        echo "종료합니다."
        exit 0
        ;;
    *)
        echo "잘못된 선택입니다."
        exit 1
        ;;
esac

#!/usr/bin/env bash
# Terraform apply 상태 확인 스크립트

LOG_FILE="terraform-apply.log"
PID_FILE="terraform-apply.pid"

echo "=== Terraform Apply 상태 확인 ==="
echo ""

# 백그라운드 프로세스 확인
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "✅ Terraform apply 프로세스가 실행 중입니다 (PID: $PID)"
    else
        echo "❌ Terraform apply 프로세스가 종료되었습니다"
    fi
else
    # PID 파일이 없으면 프로세스 이름으로 확인
    if pgrep -f "terraform-apply.sh" > /dev/null; then
        echo "✅ Terraform apply 프로세스가 실행 중입니다"
    else
        echo "❌ Terraform apply 프로세스가 실행되지 않았습니다"
    fi
fi

echo ""
echo "=== 최근 로그 (마지막 30줄) ==="
if [ -f "$LOG_FILE" ]; then
    tail -30 "$LOG_FILE"
else
    echo "로그 파일이 없습니다."
fi

echo ""
echo "=== 전체 로그 보기 ==="
echo "tail -f $LOG_FILE"

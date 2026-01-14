#!/bin/bash
# SSM Session Manager로 Bastion 접속

INSTANCE_ID="i-0088889a043f54312"
REGION="ap-northeast-2"

echo "SSM Session Manager로 Bastion 접속 중..."
echo "인스턴스 ID: $INSTANCE_ID"
echo "리전: $REGION"
echo ""
echo "접속 후 다음 명령어를 실행하세요:"
echo "  sudo su -"
echo "  cd /root/Backend"
echo "  export PATH=\$PATH:/root/.local/bin"
echo "  python3 <<'PYEOF'"
echo "  import sys"
echo "  sys.path.insert(0, '.')"
echo "  from app.core.config import settings"
echo "  from app.core.database import engine"
echo "  from sqlalchemy import text"
echo "  try:"
echo "      with engine.connect() as conn:"
echo "          result = conn.execute(text('SELECT 1 as test'))"
echo "          row = result.fetchone()"
echo "          print(f'✅ 연결 성공! 테스트 쿼리 결과: {row[0]}')"
echo "  except Exception as e:"
echo "      print(f'❌ 연결 실패: {e}')"
echo "  PYEOF"
echo ""

aws ssm start-session --target $INSTANCE_ID --region $REGION

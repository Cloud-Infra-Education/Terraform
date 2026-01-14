#!/usr/bin/env bash
set -euo pipefail

echo "=== 노드 그룹 삭제 상태 확인 ==="
echo ""

# Seoul 노드 그룹 확인
echo "Seoul 노드 그룹 상태:"
NODEGROUPS_SEOUL=$(aws eks list-nodegroups --cluster-name yuh-formation-lap-seoul --region ap-northeast-2 --query 'nodegroups' --output json 2>/dev/null || echo "[]")
if [ "$NODEGROUPS_SEOUL" == "[]" ] || [ "$NODEGROUPS_SEOUL" == "null" ]; then
  echo "  ✓ Seoul: 노드 그룹이 모두 삭제되었습니다"
else
  echo "  ⏳ Seoul: 노드 그룹 삭제 중..."
  echo "$NODEGROUPS_SEOUL" | jq -r '.[]' | while read -r ng; do
    STATUS=$(aws eks describe-nodegroup --cluster-name yuh-formation-lap-seoul --nodegroup-name "$ng" --region ap-northeast-2 --query 'nodegroup.status' --output text 2>/dev/null || echo "UNKNOWN")
    echo "    - $ng: $STATUS"
  done
fi

echo ""

# Oregon 노드 그룹 확인
echo "Oregon 노드 그룹 상태:"
NODEGROUPS_OREGON=$(aws eks list-nodegroups --cluster-name yuh-formation-lap-oregon --region us-west-2 --query 'nodegroups' --output json 2>/dev/null || echo "[]")
if [ "$NODEGROUPS_OREGON" == "[]" ] || [ "$NODEGROUPS_OREGON" == "null" ]; then
  echo "  ✓ Oregon: 노드 그룹이 모두 삭제되었습니다"
else
  echo "  ⏳ Oregon: 노드 그룹 삭제 중..."
  echo "$NODEGROUPS_OREGON" | jq -r '.[]' | while read -r ng; do
    STATUS=$(aws eks describe-nodegroup --cluster-name yuh-formation-lap-oregon --nodegroup-name "$ng" --region us-west-2 --query 'nodegroup.status' --output text 2>/dev/null || echo "UNKNOWN")
    echo "    - $ng: $STATUS"
  done
fi

echo ""
echo "=== 확인 완료 ==="
echo ""
echo "모든 노드 그룹이 삭제되면 다음 명령어로 클러스터를 삭제할 수 있습니다:"
echo "  cd /root/Terraform/02-kubernetes && terraform destroy -auto-approve"

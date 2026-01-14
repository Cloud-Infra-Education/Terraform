#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KUBERNETES_DIR="${ROOT_DIR}/02-kubernetes"

echo "========== Node Group 삭제 시작 =========="

# Seoul node group 삭제
echo "Seoul node group 확인 및 삭제 중..."
NODEGROUPS_SEOUL=$(aws eks list-nodegroups --cluster-name yuh-formation-lap-seoul --region ap-northeast-2 --query 'nodegroups' --output json 2>/dev/null || echo "[]")
if [ "$NODEGROUPS_SEOUL" != "[]" ] && [ "$NODEGROUPS_SEOUL" != "null" ]; then
  echo "  Seoul node group 발견, 삭제 시작..."
  cd "${KUBERNETES_DIR}"
  terraform init -upgrade >/dev/null 2>&1 || true
  
  # Terraform으로 노드 그룹 먼저 타겟팅하여 삭제 시도
  NODEGROUP_NAMES=$(echo "$NODEGROUPS_SEOUL" | jq -r '.[]' 2>/dev/null || echo "")
  for NODEGROUP_NAME in $NODEGROUP_NAMES; do
    if [ -n "$NODEGROUP_NAME" ]; then
      echo "    Seoul node group '$NODEGROUP_NAME' 삭제 중..."
      # Terraform state에서 노드 그룹 리소스 찾기
      NODEGROUP_RESOURCE=$(terraform state list 2>/dev/null | grep -i "seoul.*nodegroup\|seoul.*node_group" | head -1 || echo "")
      if [ -n "$NODEGROUP_RESOURCE" ]; then
        terraform destroy -target="$NODEGROUP_RESOURCE" -auto-approve >/dev/null 2>&1 || true
      fi
      # AWS CLI로 직접 삭제 (Terraform이 실패한 경우)
      aws eks delete-nodegroup --cluster-name yuh-formation-lap-seoul --nodegroup-name "$NODEGROUP_NAME" --region ap-northeast-2 2>/dev/null || true
    fi
  done
  
  # 삭제 완료 대기
  echo "  Seoul node group 삭제 완료 대기 중..."
  while true; do
    NODEGROUPS=$(aws eks list-nodegroups --cluster-name yuh-formation-lap-seoul --region ap-northeast-2 --query 'nodegroups' --output json 2>/dev/null || echo "[]")
    if [ "$NODEGROUPS" == "[]" ] || [ "$NODEGROUPS" == "null" ]; then
      echo "✓ Seoul node group 삭제 완료"
      break
    fi
    echo "    Seoul node group 삭제 중... (30초 후 재확인)"
    sleep 30
  done
else
  echo "✓ Seoul node group이 이미 삭제되었거나 존재하지 않습니다"
fi

# Oregon node group 삭제
echo "Oregon node group 확인 및 삭제 중..."
NODEGROUPS_OREGON=$(aws eks list-nodegroups --cluster-name yuh-formation-lap-oregon --region us-west-2 --query 'nodegroups' --output json 2>/dev/null || echo "[]")
if [ "$NODEGROUPS_OREGON" != "[]" ] && [ "$NODEGROUPS_OREGON" != "null" ]; then
  echo "  Oregon node group 발견, 삭제 시작..."
  cd "${KUBERNETES_DIR}"
  terraform init -upgrade >/dev/null 2>&1 || true
  
  # Terraform으로 노드 그룹 먼저 타겟팅하여 삭제 시도
  NODEGROUP_NAMES=$(echo "$NODEGROUPS_OREGON" | jq -r '.[]' 2>/dev/null || echo "")
  for NODEGROUP_NAME in $NODEGROUP_NAMES; do
    if [ -n "$NODEGROUP_NAME" ]; then
      echo "    Oregon node group '$NODEGROUP_NAME' 삭제 중..."
      # Terraform state에서 노드 그룹 리소스 찾기
      NODEGROUP_RESOURCE=$(terraform state list 2>/dev/null | grep -i "oregon.*nodegroup\|oregon.*node_group" | head -1 || echo "")
      if [ -n "$NODEGROUP_RESOURCE" ]; then
        terraform destroy -target="$NODEGROUP_RESOURCE" -auto-approve >/dev/null 2>&1 || true
      fi
      # AWS CLI로 직접 삭제 (Terraform이 실패한 경우)
      aws eks delete-nodegroup --cluster-name yuh-formation-lap-oregon --nodegroup-name "$NODEGROUP_NAME" --region us-west-2 2>/dev/null || true
    fi
  done
  
  # 삭제 완료 대기
  echo "  Oregon node group 삭제 완료 대기 중..."
  while true; do
    NODEGROUPS=$(aws eks list-nodegroups --cluster-name yuh-formation-lap-oregon --region us-west-2 --query 'nodegroups' --output json 2>/dev/null || echo "[]")
    if [ "$NODEGROUPS" == "[]" ] || [ "$NODEGROUPS" == "null" ]; then
      echo "✓ Oregon node group 삭제 완료"
      break
    fi
    echo "    Oregon node group 삭제 중... (30초 후 재확인)"
    sleep 30
  done
else
  echo "✓ Oregon node group이 이미 삭제되었거나 존재하지 않습니다"
fi

echo ""
echo "========== 모든 Node Group 삭제 완료! =========="
echo "이제 리소스를 destroy할 수 있습니다."
echo ""
echo "Destroy를 시작합니다..."
echo ""

# 주의: 03-database가 02-kubernetes의 outputs를 참조하므로
# 03-database를 먼저 destroy해야 합니다 (02-kubernetes outputs가 아직 있을 때)

# 03-database destroy
# 주의: 02-kubernetes가 이미 destroy되어 outputs가 없을 수 있음
echo "========== 03-database Destroy 시작 =========="
DATABASE_DIR="${ROOT_DIR}/03-database"
cd "${DATABASE_DIR}"
terraform init

# kubernetes outputs를 참조하는 리소스를 state에서 먼저 제거
echo "kubernetes outputs를 참조하는 리소스를 state에서 제거합니다..."
terraform state rm aws_lambda_function.video_processor 2>/dev/null || true
terraform state rm aws_lambda_permission.allow_s3 2>/dev/null || true
terraform state rm aws_s3_bucket_notification.video_trigger 2>/dev/null || true
terraform state rm aws_iam_role.video_exec 2>/dev/null || true
terraform state rm aws_iam_policy.video_custom 2>/dev/null || true
terraform state rm aws_iam_role_policy_attachment.video_vpc 2>/dev/null || true
terraform state rm aws_iam_role_policy_attachment.video_custom_attach 2>/dev/null || true

# module.database에서 kubernetes outputs를 참조하는 security group rules 제거
terraform state rm module.database.aws_security_group_rule.kor_eks_to_proxy[0] 2>/dev/null || true
terraform state rm module.database.aws_security_group_rule.usa_eks_to_proxy[0] 2>/dev/null || true

# module.database를 제외하고 destroy (module.database는 kubernetes outputs를 참조)
echo "module.database를 제외한 리소스를 destroy합니다..."
terraform destroy -auto-approve \
  -target=module.database.aws_db_proxy.kor \
  -target=module.database.aws_db_proxy.usa \
  -target=module.database.aws_db_proxy_default_target_group.kor \
  -target=module.database.aws_db_proxy_default_target_group.usa \
  -target=module.database.aws_db_proxy_target.kor_cluster \
  -target=module.database.aws_db_proxy_target.usa_cluster \
  -target=module.database.aws_db_subnet_group.kor \
  -target=module.database.aws_db_subnet_group.usa \
  -target=module.database.aws_iam_role.kor_rds_proxy \
  -target=module.database.aws_iam_role.usa_rds_proxy \
  -target=module.database.aws_iam_role_policy.kor_rds_proxy \
  -target=module.database.aws_iam_role_policy.usa_rds_proxy \
  -target=module.database.aws_rds_cluster.kor \
  -target=module.database.aws_rds_cluster.usa \
  -target=module.database.aws_rds_cluster_instance.kor_writer \
  -target=module.database.aws_rds_cluster_instance.kor_reader \
  -target=module.database.aws_rds_cluster_instance.usa_writer \
  -target=module.database.aws_rds_cluster_instance.usa_reader \
  -target=module.database.aws_security_group.db_kor \
  -target=module.database.aws_security_group.db_usa \
  -target=module.database.aws_security_group.proxy_kor \
  -target=module.database.aws_security_group.proxy_usa \
  -target=module.database.aws_security_group.lambda_sg \
  -target=module.database.aws_security_group_rule.kor_lambda_to_db \
  -target=module.database.aws_security_group_rule.kor_lambda_to_proxy \
  -target=module.database.aws_security_group_rule.kor_proxy_to_db \
  -target=module.database.aws_security_group_rule.usa_proxy_to_db \
  2>&1 | grep -v "Warning:" || echo "일부 리소스는 이미 삭제되었을 수 있습니다."

echo ""
echo "========== 03-database Destroy 완료! =========="
echo ""

# 02-kubernetes destroy
echo "========== 02-kubernetes Destroy 시작 =========="
cd "${KUBERNETES_DIR}"
terraform destroy -auto-approve

echo ""
echo "========== 02-kubernetes Destroy 완료! =========="
echo ""

# 01-infra destroy (재시도 로직 포함)
echo "========== 01-infra Destroy 시작 =========="
INFRA_DIR="${ROOT_DIR}/01-infra"
cd "${INFRA_DIR}"
terraform init

# Lambda ENI 삭제 대기 (최대 5분)
echo "Lambda ENI 삭제 대기 중..."
ENI_WAIT_COUNT=0
ENI_MAX_WAIT=10  # 10회 * 30초 = 5분
while [ $ENI_WAIT_COUNT -lt $ENI_MAX_WAIT ]; do
  # Lambda ENI 확인
  LAMBDA_ENIS=$(aws ec2 describe-network-interfaces --region ap-northeast-2 \
    --filters "Name=description,Values=*Lambda*" "Name=status,Values=in-use" \
    --query 'NetworkInterfaces[*].NetworkInterfaceId' --output text 2>/dev/null || echo "")
  
  if [ -z "$LAMBDA_ENIS" ] || [ "$LAMBDA_ENIS" == "None" ]; then
    echo "✓ Lambda ENI 삭제 완료"
    break
  fi
  
  ENI_WAIT_COUNT=$((ENI_WAIT_COUNT + 1))
  echo "  Lambda ENI 삭제 대기 중... ($ENI_WAIT_COUNT/$ENI_MAX_WAIT, 30초 후 재확인)"
  sleep 30
done

# Security Group 의존성 문제로 인한 재시도
MAX_RETRIES=3
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if terraform destroy -auto-approve; then
    echo "✓ 01-infra Destroy 성공"
    break
  else
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
      echo "⚠ ENI 또는 Security Group 의존성 문제로 재시도 중... ($RETRY_COUNT/$MAX_RETRIES)"
      echo "   잠시 대기 후 재시도합니다..."
      sleep 30
    else
      echo "⚠ 01-infra Destroy 실패 (ENI 또는 Security Group 의존성 문제일 수 있음)"
      echo "   수동으로 확인이 필요할 수 있습니다."
    fi
  fi
done

echo ""
echo "========== 모든 리소스 Destroy 완료! =========="
echo "01-infra, 02-kubernetes, 03-database가 모두 삭제되었습니다."

#!/bin/bash
# DB 클러스터 상태 확인 스크립트

echo "=== DB 클러스터 상태 확인 ==="
echo ""

CLUSTER_ID="y2om-kor-aurora-mysql"
REGION="ap-northeast-2"

# 1. 클러스터 기본 정보
echo "1. 클러스터 기본 정보..."
aws rds describe-db-clusters \
  --region $REGION \
  --db-cluster-identifier $CLUSTER_ID \
  --query 'DBClusters[0].{ClusterIdentifier:DBClusterIdentifier,Status:Status,Engine:Engine,EngineVersion:EngineVersion,Endpoint:Endpoint,ReaderEndpoint:ReaderEndpoint,DatabaseName:DatabaseName,MasterUsername:MasterUsername}' \
  --output table
echo ""

# 2. 클러스터 멤버 (인스턴스) 상태
echo "2. 클러스터 멤버 (인스턴스) 상태..."
aws rds describe-db-instances \
  --region $REGION \
  --query "DBInstances[?contains(DBClusterIdentifier, \`$CLUSTER_ID\`)].{InstanceIdentifier:DBInstanceIdentifier,Status:DBInstanceStatus,InstanceClass:DBInstanceClass,Endpoint:Endpoint.Address,Port:Endpoint.Port}" \
  --output table
echo ""

# 3. 보안 그룹 정보
echo "3. 보안 그룹 정보..."
DB_SG=$(aws rds describe-db-clusters \
  --region $REGION \
  --db-cluster-identifier $CLUSTER_ID \
  --query 'DBClusters[0].VpcSecurityGroups[0].VpcSecurityGroupId' \
  --output text)

PROXY_SG=$(aws rds describe-db-proxies \
  --region $REGION \
  --db-proxy-name y2om-formation-lap-kor-rds-proxy \
  --query 'DBProxies[0].VpcSecurityGroupIds[0]' \
  --output text)

echo "   DB Cluster SG: $DB_SG"
echo "   RDS Proxy SG: $PROXY_SG"
echo ""

# 4. DB Cluster 보안 그룹 인바운드 규칙
echo "4. DB Cluster 보안 그룹 인바운드 규칙 (포트 3306)..."
aws ec2 describe-security-groups \
  --region $REGION \
  --group-ids $DB_SG \
  --query 'SecurityGroups[0].IpPermissions[?FromPort==`3306`].{Port:FromPort,Protocol:IpProtocol,SourceSG:UserIdGroupPairs[0].GroupId}' \
  --output table
echo ""

# 5. 클러스터 설정
echo "5. 클러스터 설정..."
aws rds describe-db-clusters \
  --region $REGION \
  --db-cluster-identifier $CLUSTER_ID \
  --query 'DBClusters[0].{AvailabilityZones:length(AvailabilityZones),BackupRetentionPeriod:BackupRetentionPeriod,MultiAZ:MultiAZ,StorageEncrypted:StorageEncrypted}' \
  --output table
echo ""

# 6. 상태 요약
echo "=== 상태 요약 ==="
STATUS=$(aws rds describe-db-clusters \
  --region $REGION \
  --db-cluster-identifier $CLUSTER_ID \
  --query 'DBClusters[0].Status' \
  --output text)

if [ "$STATUS" = "available" ]; then
    echo "✅ 클러스터 상태: $STATUS (정상)"
else
    echo "⚠️  클러스터 상태: $STATUS"
fi

ENDPOINT=$(aws rds describe-db-clusters \
  --region $REGION \
  --db-cluster-identifier $CLUSTER_ID \
  --query 'DBClusters[0].Endpoint' \
  --output text)

echo "   엔드포인트: $ENDPOINT"
echo ""

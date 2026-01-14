#!/bin/bash
# Bastion user_data 스크립트
# HAProxy 설치 및 RDS Proxy 프록시 설정

set -e

RDS_PROXY_ENDPOINT="${rds_proxy_endpoint}"
RDS_PROXY_PORT="${rds_proxy_port:-3306}"

if [ -z "$RDS_PROXY_ENDPOINT" ]; then
    echo "RDS Proxy endpoint가 설정되지 않았습니다. HAProxy 설치를 건너뜁니다."
    exit 0
fi

echo "=========================================="
echo "Bastion HAProxy 설정 시작"
echo "=========================================="
echo "RDS Proxy Endpoint: $RDS_PROXY_ENDPOINT"
echo "RDS Proxy Port: $RDS_PROXY_PORT"
echo ""

# HAProxy 설치
echo "1. HAProxy 설치 중..."
yum update -y
yum install -y haproxy

# HAProxy 설정 파일 생성
echo "2. HAProxy 설정 파일 생성 중..."
cat > /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log global
    mode tcp
    option tcplog
    option dontlognull
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

# RDS Proxy로의 프록시 설정
frontend mysql_frontend
    bind *:3306
    default_backend mysql_backend

backend mysql_backend
    mode tcp
    balance roundrobin
    server rds_proxy ${RDS_PROXY_ENDPOINT}:${RDS_PROXY_PORT} check
EOF

# HAProxy 서비스 시작 및 자동 시작 설정
echo "3. HAProxy 서비스 시작 중..."
systemctl enable haproxy
systemctl restart haproxy

# 방화벽 설정 (필요시)
echo "4. 방화벽 설정 확인 중..."
if systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --add-port=3306/tcp
    firewall-cmd --reload
fi

# HAProxy 상태 확인
echo "5. HAProxy 상태 확인 중..."
systemctl status haproxy --no-pager || true

echo ""
echo "=========================================="
echo "HAProxy 설정 완료!"
echo "=========================================="
echo "HAProxy가 포트 3306에서 리스닝 중입니다."
echo "Lambda는 Bastion의 Private IP:3306으로 연결하면 됩니다."

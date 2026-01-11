# 1. Customer Gateway (로컬 장비의 공인 IP 등록)
resource "aws_customer_gateway" "onprem_cgw" {
  provider   = aws.seoul
  bgp_asn    = 65000
  ip_address = var.onprem_public_ip
  type       = "ipsec.1"

  tags = { Name = "y2om-OnPrem-CGW" }
}

# 2. Site-to-Site VPN Connection (서울 Transit Gateway에 연결)
resource "aws_vpn_connection" "onprem_to_seoul_vpn" {
  provider            = aws.seoul
  customer_gateway_id = aws_customer_gateway.onprem_cgw.id
  transit_gateway_id  = aws_ec2_transit_gateway.kor.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = { Name = "y2om-VPN-to-Seoul-TGW" }
}

# 3. TGW 정적 경로 추가 (TGW가 로컬 대역을 인식하도록)
resource "aws_ec2_transit_gateway_route" "tgw_route_to_onprem" {
  provider                       = aws.seoul
  destination_cidr_block         = var.onprem_private_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway.kor.association_default_route_table_id
  transit_gateway_attachment_id  = aws_vpn_connection.onprem_to_seoul_vpn.transit_gateway_attachment_id
}

# 4. 서울 VPC의 모든 프라이빗 라우팅 테이블에 로컬 경로 추가
# module.kor_vpc가 route_table_ids를 출력(output)한다고 가정합니다.
resource "aws_route" "kor_private_to_onprem" {
  provider               = aws.seoul
  count                  = length(module.kor_vpc.private_route_table_ids)
  route_table_id         = module.kor_vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.onprem_private_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.kor.id
}

# 5. 서울 VPC의 퍼블릭 라우팅 테이블에도 추가 (배스천 호스트용)
resource "aws_route" "kor_public_to_onprem" {
  provider               = aws.seoul
  count                  = length(module.kor_vpc.public_route_table_ids)
  route_table_id         = module.kor_vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.onprem_private_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.kor.id
}

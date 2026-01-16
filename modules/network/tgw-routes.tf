# ============================================================
# Transit Gateway 리전 간 라우팅 설정
# - 에러 해결: 수락 리소스 이름을 usa_accept로 수정
# ============================================================

# 1) 서울 -> 미국(오레곤) 경로
resource "aws_ec2_transit_gateway_route" "kor_to_usa_default" {
  provider   = aws.seoul
  
  # tgw-peering.tf에 정의된 실제 리소스 이름을 사용합니다.
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.usa_accept]

  transit_gateway_route_table_id = aws_ec2_transit_gateway.kor.association_default_route_table_id
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id
}

# 2) 미국(오레곤) -> 서울 경로
resource "aws_ec2_transit_gateway_route" "usa_to_kor_default" {
  provider   = aws.oregon
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.usa_accept]

  transit_gateway_route_table_id = aws_ec2_transit_gateway.usa.association_default_route_table_id
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id
}

# 3) 미국(오레곤) -> 온프레미스(서울 오피스) 경로
resource "aws_ec2_transit_gateway_route" "usa_to_office_via_peering" {
  provider   = aws.oregon
  
  depends_on = [aws_ec2_transit_gateway_peering_attachment_accepter.usa_accept]

  transit_gateway_route_table_id = aws_ec2_transit_gateway.usa.association_default_route_table_id
  destination_cidr_block         = var.onprem_private_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id
}

# 4) 미국(오레곤) VPC 서브넷 라우트 테이블 설정
resource "aws_route" "usa_to_onprem" {
  provider               = aws.oregon
  count                  = length(module.usa_vpc.private_route_table_ids)
  route_table_id         = module.usa_vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.onprem_private_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.usa.id
  
  depends_on = [aws_ec2_transit_gateway_route.usa_to_office_via_peering]
}

resource "aws_ec2_transit_gateway_peering_attachment" "kor_to_usa" {
  provider                = aws.seoul
  transit_gateway_id      = aws_ec2_transit_gateway.kor.id
  peer_transit_gateway_id = aws_ec2_transit_gateway.usa.id
  peer_region             = "us-west-2"

  tags = {
    Name = "KOR-USA-TGW-Peering"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "usa_accept" {
  provider                      = aws.oregon
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id

  tags = {
    Name = "USA-Accept-KOR-TGW"
  }
}
resource "aws_ec2_transit_gateway_route" "kor_to_usa_default" {
  provider   = aws.seoul
  depends_on = [time_sleep.wait_for_tgw]

  transit_gateway_route_table_id = aws_ec2_transit_gateway.kor.association_default_route_table_id
  destination_cidr_block         = "10.223.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id
}

resource "aws_ec2_transit_gateway_route" "usa_to_kor_default" {
  provider   = aws.oregon
  depends_on = [time_sleep.wait_for_tgw]

  transit_gateway_route_table_id = aws_ec2_transit_gateway.usa.association_default_route_table_id
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id
}

resource "aws_ec2_transit_gateway_route" "usa_to_office_via_peering" {
  provider   = aws.oregon
  depends_on = [time_sleep.wait_for_tgw]

  transit_gateway_route_table_id = aws_ec2_transit_gateway.usa.association_default_route_table_id
  destination_cidr_block         = var.onprem_private_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id
}

resource "aws_route" "usa_to_onprem" {
  provider               = aws.oregon
  count                  = length(module.usa_vpc.private_route_table_ids)
  route_table_id         = module.usa_vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.onprem_private_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.usa.id
}
resource "aws_ec2_transit_gateway_route_table" "kor" {
  provider           = aws.seoul
  transit_gateway_id = aws_ec2_transit_gateway.kor.id

  tags = {
    Name = "KOR-TGW-RT"
  }
}

resource "aws_ec2_transit_gateway_route_table" "usa" {
  provider           = aws.oregon
  transit_gateway_id = aws_ec2_transit_gateway.usa.id

  tags = {
    Name = "USA-TGW-RT"
  }
}

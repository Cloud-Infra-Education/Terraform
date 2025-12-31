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

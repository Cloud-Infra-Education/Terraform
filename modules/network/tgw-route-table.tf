resource "aws_ec2_transit_gateway_route_table" "kor" {
  provider           = aws.seoul
  transit_gateway_id = aws_ec2_transit_gateway.kor.id

  tags = {
    Name = "y2om-KOR-TGW-RT"
  }
}

resource "aws_ec2_transit_gateway_route_table" "usa" {
  provider           = aws.oregon
  transit_gateway_id = aws_ec2_transit_gateway.usa.id

  tags = {
    Name = "y2om-USA-TGW-RT"
  }
}

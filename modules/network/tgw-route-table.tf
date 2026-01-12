resource "aws_ec2_transit_gateway_route_table" "kor" {
  provider           = aws.seoul
  transit_gateway_id = aws_ec2_transit_gateway.kor.id

  tags = {
    Name = "KOR1-TGW-RT"
  }
}

resource "aws_ec2_transit_gateway_route_table" "usa" {
  provider           = aws.oregon
  transit_gateway_id = aws_ec2_transit_gateway.usa.id

  tags = {
    Name = "USA1-TGW-RT"
  }
}

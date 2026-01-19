resource "aws_ec2_transit_gateway" "kor" {
  provider    = aws.seoul
  description = "KOR Transit Gateway"

  tags = {
    Name = "TGW-KOR" 
  }
}


resource "aws_ec2_transit_gateway" "usa" {
  provider    = aws.oregon
  description = "USA Transit Gateway"

  tags = {
    Name = "TGW-USA"
  }
}

resource "time_sleep" "wait_for_tgw" {
  depends_on = [
    module.kor_vpc,
    module.usa_vpc,
    aws_ec2_transit_gateway_peering_attachment.kor_to_usa
  ]

  create_duration = "180s"
}


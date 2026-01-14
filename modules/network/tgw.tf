data "aws_caller_identity" "usa" {
  provider = aws.oregon
}

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

resource "aws_ec2_transit_gateway_peering_attachment" "kor_to_usa" {
  provider = aws.seoul

  peer_account_id         = data.aws_caller_identity.usa.account_id
  peer_region             = "us-west-2"
  peer_transit_gateway_id = aws_ec2_transit_gateway.usa.id
  transit_gateway_id      = aws_ec2_transit_gateway.kor.id

  tags = {
    Name = "KOR-to-USA-TGW-Peering"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "usa_accept" {
  provider = aws.oregon

  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id

  tags = {
    Name = "USA-Accept-KOR-TGW-Peering"
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

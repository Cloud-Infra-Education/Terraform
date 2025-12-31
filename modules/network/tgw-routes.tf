resource "aws_ec2_transit_gateway_route" "kor_to_usa_default" {
  provider   = aws.seoul
  depends_on = [time_sleep.wait_for_tgw]

  transit_gateway_route_table_id = aws_ec2_transit_gateway.kor.association_default_route_table_id
  destination_cidr_block         = "10.1.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id
}

resource "aws_ec2_transit_gateway_route" "usa_to_kor_default" {
  provider   = aws.oregon
  depends_on = [time_sleep.wait_for_tgw]

  transit_gateway_route_table_id = aws_ec2_transit_gateway.usa.association_default_route_table_id
  destination_cidr_block         = "10.0.0.0/16"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.kor_to_usa.id
}

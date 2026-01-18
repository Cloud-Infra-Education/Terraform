resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = aws_subnet.tgw[*].id

  tags = {
    Name = "${var.name}-tgw-attach"
  }
}

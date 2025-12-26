output "tgw_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.this.id
}
output "vpc_id" {
  value = aws_vpc.this.id
}
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}


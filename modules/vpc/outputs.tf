output "tgw_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.this.id
}
output "vpc_id" {
  value = aws_vpc.this.id
}
output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}
output "private_eks_subnet_ids" {
  value = [
    for s in aws_subnet.private : s.id
    if startswith(try(s.tags["Name"], ""), "y2om-PrivateSubnet-EKS-")
  ]
}
output "private_db_subnet_ids" {
  value = [
    for s in aws_subnet.private : s.id
    if startswith(try(s.tags["Name"], ""), "y2om-PrivateSubnet-DB-")
  ]
}

output "private_route_table_ids" {
  value = [aws_route_table.private.id]
}
output "public_route_table_ids" {
  value = [aws_route_table.public.id]
}

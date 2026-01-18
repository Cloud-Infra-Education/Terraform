output "vpn_connection_id" {
  value = aws_vpn_connection.this.id
}

output "transit_gateway_attachment_id" {
  value = aws_vpn_connection.this.transit_gateway_attachment_id
}

output "tunnel1_address" {
  value = aws_vpn_connection.this.tunnel1_address
}

output "tunnel2_address" {
  value = aws_vpn_connection.this.tunnel2_address
}

output "tunnel1_preshared_key" {
  value     = aws_vpn_connection.this.tunnel1_preshared_key
  sensitive = true
}

output "tunnel2_preshared_key" {
  value     = aws_vpn_connection.this.tunnel2_preshared_key
  sensitive = true
}


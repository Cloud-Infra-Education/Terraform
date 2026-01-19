resource "aws_customer_gateway" "this" {
  bgp_asn    = var.bgp_asn
  ip_address = var.onprem_public_ip
  type       = "ipsec.1"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cgw"
  })
}

resource "aws_vpn_connection" "this" {
  customer_gateway_id = aws_customer_gateway.this.id
  transit_gateway_id  = var.transit_gateway_id
  type                = "ipsec.1"
  static_routes_only  = var.static_routes_only

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpn"
  })
}


resource "aws_ec2_transit_gateway_route" "to_onprem" {
  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  destination_cidr_block         = var.onprem_private_cidr
  transit_gateway_attachment_id  = aws_vpn_connection.this.transit_gateway_attachment_id
}


resource "aws_ec2_tag" "vpn_attachment_tags" {
  for_each = var.tag_tgw_vpn_attachment ? merge(var.tags, { Name = "${var.name_prefix}-vpn-attach" }) : {}

  resource_id = aws_vpn_connection.this.transit_gateway_attachment_id
  key         = each.key
  value       = each.value
}


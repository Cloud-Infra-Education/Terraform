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

# 중요:
# TGW에 붙인 VPN은 aws_vpn_connection_route로 static route 추가가 불가합니다.
# (InvalidVpnConnection.InvalidType 발생)
# 온프레 CIDR 라우팅은 TGW Route Table에 route로만 관리합니다.

resource "aws_ec2_transit_gateway_route" "to_onprem" {
  for_each = var.create_tgw_routes_to_onprem ? toset(var.onprem_private_cidrs) : toset([])

  transit_gateway_route_table_id = var.transit_gateway_route_table_id
  destination_cidr_block         = each.value
  transit_gateway_attachment_id  = aws_vpn_connection.this.transit_gateway_attachment_id
}

resource "aws_ec2_tag" "vpn_attachment_tags" {
  for_each = var.tag_tgw_vpn_attachment ? merge(var.tags, { Name = "${var.name_prefix}-vpn-attach" }) : {}

  resource_id = aws_vpn_connection.this.transit_gateway_attachment_id
  key         = each.key
  value       = each.value
}


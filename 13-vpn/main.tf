locals {
  onprem_cidrs = length(var.onprem_private_cidrs) > 0 ? var.onprem_private_cidrs : (
    var.onprem_private_cidr != "" ? [var.onprem_private_cidr] : []
  )

  seoul_vpc_id = var.seoul_vpc_id != "" ? var.seoul_vpc_id : data.terraform_remote_state.infra.outputs.kor_vpc_id
  seoul_tgw_id = data.terraform_remote_state.infra.outputs.kor_tgw_id
}

data "aws_ec2_transit_gateway" "seoul" {
  provider = aws.seoul
  id       = local.seoul_tgw_id
}

locals {
  seoul_tgw_rt_id = var.seoul_tgw_route_table_id != "" ? var.seoul_tgw_route_table_id : data.aws_ec2_transit_gateway.seoul.association_default_route_table_id
}

module "vpn" {
  source = "../modules/vpn"

  providers = {
    aws = aws.seoul
  }

  name_prefix                    = "seoul-onprem"
  transit_gateway_id             = local.seoul_tgw_id
  transit_gateway_route_table_id = local.seoul_tgw_rt_id

  onprem_public_ip     = var.onprem_public_ip
  onprem_private_cidrs = local.onprem_cidrs

  static_routes_only           = true
  create_tgw_routes_to_onprem  = true
  tag_tgw_vpn_attachment       = true
}

data "aws_route_tables" "seoul_vpc_all" {
  provider = aws.seoul

  filter {
    name   = "vpc-id"
    values = [local.seoul_vpc_id]
  }
}

locals {
  target_vpc_rt_ids = length(var.vpc_route_table_ids) > 0 ? var.vpc_route_table_ids : data.aws_route_tables.seoul_vpc_all.ids

  vpc_route_pairs = var.manage_vpc_routes ? {
    for pair in flatten([
      for rt_id in local.target_vpc_rt_ids : [
        for cidr in local.onprem_cidrs : {
          k    = "${rt_id}||${cidr}"
          rt   = rt_id
          cidr = cidr
        }
      ]
    ]) : pair.k => pair
  } : {}
}

resource "aws_route" "vpc_to_onprem_via_tgw" {
  provider = aws.seoul
  for_each = local.vpc_route_pairs

  route_table_id         = each.value.rt
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = local.seoul_tgw_id
}

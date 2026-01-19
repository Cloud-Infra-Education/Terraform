# ==========================================
# Seoul TGW <-> On-Prem Static Site-to-Site VPN
# - strongSwan 설정 파일을 generated/ 아래로 자동 생성
# ==========================================

# 기존에 생성된 TGW를 태그(Name)로 조회해서 사용
# (필요 시 values 값을 환경에 맞게 수정)
data "aws_ec2_transit_gateway" "kor" {
  provider = aws.seoul

  filter {
    name   = "tag:Name"
    values = ["TGW-KOR"]  
  }
  filter {
    name   = "state"
    values = ["available"]
  }
  depends_on = [aws_ec2_transit_gateway.kor]  # Transit Gateway 생성 후 조회

}

data "aws_vpc" "kor" {
  provider = aws.seoul
  id       = module.kor_vpc.vpc_id
}

data "aws_vpc" "usa" {
  provider = aws.oregon
  id       = module.usa_vpc.vpc_id
}

locals {
  generated_dir    = "${path.root}/generated"
  aws_rightsubnets = join(",", [data.aws_vpc.kor.cidr_block, data.aws_vpc.usa.cidr_block])
}

resource "aws_customer_gateway" "onprem_cgw" {
  provider   = aws.seoul
  bgp_asn    = 65000
  ip_address = var.onprem_public_ip
  type       = "ipsec.1"

  tags = { Name = "OnPrem-CGW" }
}

resource "aws_vpn_connection" "onprem_to_seoul_vpn" {
  provider            = aws.seoul
  customer_gateway_id = aws_customer_gateway.onprem_cgw.id
  transit_gateway_id  = data.aws_ec2_transit_gateway.kor.id
  type                = "ipsec.1"
  static_routes_only  = true

  depends_on = [aws_ec2_transit_gateway.kor]

  tags = { Name = "VPN-to-Seoul-TGW" }
}

resource "aws_ec2_transit_gateway_route" "tgw_route_to_onprem" {
  provider                       = aws.seoul
  destination_cidr_block         = var.onprem_private_cidr
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway.kor.association_default_route_table_id
  transit_gateway_attachment_id  = aws_vpn_connection.onprem_to_seoul_vpn.transit_gateway_attachment_id
}

resource "aws_route" "kor_private_to_onprem" {
  provider               = aws.seoul
  count                  = length(module.kor_vpc.private_route_table_ids)
  route_table_id         = module.kor_vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.onprem_private_cidr
  transit_gateway_id     = data.aws_ec2_transit_gateway.kor.id
}

resource "aws_route" "kor_public_to_onprem" {
  provider               = aws.seoul
  count                  = length(module.kor_vpc.public_route_table_ids)
  route_table_id         = module.kor_vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.onprem_private_cidr
  transit_gateway_id     = data.aws_ec2_transit_gateway.kor.id
}

# ------------------------------------------
# strongSwan 설정 파일 자동 생성
# - 출력 위치: <terraform 실행 디렉토리>/generated/
# ------------------------------------------

resource "local_file" "strongswan_ipsec_conf" {
  filename        = "${local.generated_dir}/ipsec.conf"
  file_permission = "0644"

  content = templatefile("${path.module}/templates/ipsec.conf.tftpl", {
    onprem_public_ip    = var.onprem_public_ip
    onprem_private_cidr = var.onprem_private_cidr

    aws_rightsubnets = local.aws_rightsubnets

    tunnel1_address = aws_vpn_connection.onprem_to_seoul_vpn.tunnel1_address
    tunnel2_address = aws_vpn_connection.onprem_to_seoul_vpn.tunnel2_address
  })
}

resource "local_sensitive_file" "strongswan_ipsec_secrets" {
  filename        = "${local.generated_dir}/ipsec.secrets"
  file_permission = "0600"

  content = templatefile("${path.module}/templates/ipsec.secrets.tftpl", {
    onprem_public_ip = var.onprem_public_ip

    tunnel1_address = aws_vpn_connection.onprem_to_seoul_vpn.tunnel1_address
    tunnel2_address = aws_vpn_connection.onprem_to_seoul_vpn.tunnel2_address

    tunnel1_psk = aws_vpn_connection.onprem_to_seoul_vpn.tunnel1_preshared_key
    tunnel2_psk = aws_vpn_connection.onprem_to_seoul_vpn.tunnel2_preshared_key
  })
}


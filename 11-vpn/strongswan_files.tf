locals {
  aws_right_subnets  = data.terraform_remote_state.infra.outputs.kor_vpc_cidr
  onprem_left_subnet = join(",", local.onprem_cidrs)
}

resource "local_file" "ipsec_conf" {
  filename = "${path.module}/generated/ipsec.conf"

  content = templatefile("${path.module}/templates/ipsec.conf.tftpl", {
    onprem_public_ip   = var.onprem_public_ip
    onprem_left_subnet = local.onprem_left_subnet
    aws_right_subnets  = local.aws_right_subnets
    tunnel1_address    = module.vpn.tunnel1_address
    tunnel2_address    = module.vpn.tunnel2_address
    keyexchange        = var.keyexchange
    ike                = var.ike
    esp                = var.esp
    dpd_delay          = var.dpd_delay
    dpd_timeout        = var.dpd_timeout
  })
}

resource "local_file" "ipsec_secrets" {
  filename        = "${path.module}/generated/ipsec.secrets"
  file_permission = "0600"

  sensitive_content = templatefile("${path.module}/templates/ipsec.secrets.tftpl", {
    onprem_public_ip = var.onprem_public_ip
    tunnel1_address  = module.vpn.tunnel1_address
    tunnel2_address  = module.vpn.tunnel2_address
    tunnel1_psk      = module.vpn.tunnel1_preshared_key
    tunnel2_psk      = module.vpn.tunnel2_preshared_key
  })
}

output "strongswan_ipsec_conf_path" {
  value = local_file.ipsec_conf.filename
}

output "strongswan_ipsec_secrets_path" {
  value = local_file.ipsec_secrets.filename
}


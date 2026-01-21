variable "name_prefix" {
  description = "리소스 Name prefix"
  type        = string
  default     = "seoul-onprem"
}

variable "transit_gateway_id" {
  description = "서울 TGW ID"
  type        = string
}

variable "transit_gateway_route_table_id" {
  description = "온프레 CIDR 라우트를 넣을 TGW Route Table ID"
  type        = string
}

variable "onprem_public_ip" {
  description = "온프레 공인 IP (Customer Gateway)"
  type        = string
}

variable "onprem_private_cidr" {
  type        = string
}

variable "bgp_asn" {
  description = "Customer Gateway ASN"
  type        = number
  default     = 65000
}

variable "static_routes_only" {
  description = "정적 라우팅 전용"
  type        = bool
  default     = true
}

variable "create_tgw_routes_to_onprem" {
  description = "TGW RT에 onprem CIDR -> VPN attachment route 생성"
  type        = bool
  default     = true
}

variable "tag_tgw_vpn_attachment" {
  description = "TGW VPN attachment에 태그 부여"
  type        = bool
  default     = true
}

variable "tags" {
  description = "공통 태그"
  type        = map(string)
  default     = {}
}


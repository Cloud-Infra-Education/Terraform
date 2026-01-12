module "kor_vpc" {
  source    = "../vpc"
  providers = { aws = aws.seoul }

  name = "KOR1-Primary-VPC"
  cidr = "10.10.0.0/16"
  azs  = ["ap-northeast-2a", "ap-northeast-2b"]

  public_subnets      = ["10.10.1.0/24", "10.10.2.0/24"]
  public_subnet_names = ["PublicSubnet-A", "PublicSubnet-B"]

  private_subnets = [
    "10.10.11.0/24",
    "10.10.12.0/24",
    "10.10.21.0/24",
    "10.10.22.0/24"
  ]
  private_subnet_names = [
    "PrivateSubnet-EKS-A",
    "PrivateSubnet-EKS-B",
    "PrivateSubnet-DB-A",
    "PrivateSubnet-DB-B"
  ]

  tgw_subnets      = ["10.10.31.0/28", "10.10.32.0/28"]
  tgw_subnet_names = ["KOR-TGW-SubnetA", "KOR-TGW-SubnetB"]

  key_name      = var.key_name_kor
  admin_cidr    = var.admin_cidr
  tgw_id        = aws_ec2_transit_gateway.kor.id
  peer_vpc_cidr = "10.11.0.0/16"
}

module "usa_vpc" {
  source    = "../vpc"
  providers = { aws = aws.oregon }

  name = "USA1-Primary-VPC"
  cidr = "10.11.0.0/16"
  azs  = ["us-west-2a", "us-west-2b"]

  public_subnets      = ["10.11.1.0/24", "10.11.2.0/24"]
  public_subnet_names = ["PublicSubnet-A", "PublicSubnet-B"]

  private_subnets = [
    "10.11.11.0/24",
    "10.11.12.0/24",
    "10.11.21.0/24",
    "10.11.22.0/24"
  ]
  private_subnet_names = [
    "PrivateSubnet-EKS-A",
    "PrivateSubnet-EKS-B",
    "PrivateSubnet-DB-A",
    "PrivateSubnet-DB-B"
  ]

  tgw_subnets      = ["10.11.31.0/28", "10.11.32.0/28"]
  tgw_subnet_names = ["USA-TGW-SubnetA", "USA-TGW-SubnetB"]

  key_name      = var.key_name_usa
  admin_cidr    = var.admin_cidr
  tgw_id        = aws_ec2_transit_gateway.usa.id
  peer_vpc_cidr = "10.10.0.0/16"
}


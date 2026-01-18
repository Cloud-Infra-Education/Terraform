module "kor_vpc" {
  source    = "../vpc"
  providers = { aws = aws.seoul }
  onprem_private_cidr = var.onprem_private_cidr

#  name = "KOR-Primary-VPC"
  name = "chan-KOR-Primary-VPC"
#  cidr = "10.0.0.0/16"
  cidr = "10.222.0.0/16"
  azs  = ["ap-northeast-2a", "ap-northeast-2b"]

#  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets      = ["10.222.1.0/24", "10.222.2.0/24"]
  public_subnet_names = ["PublicSubnet-A", "PublicSubnet-B"]
/*
  private_subnets = [
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.21.0/24",
    "10.0.22.0/24"
  ]
*/
  private_subnets = [
    "10.222.11.0/24",
    "10.222.12.0/24",
    "10.222.21.0/24",
    "10.222.22.0/24"
  ]
  private_subnet_names = [
    "PrivateSubnet-EKS-A",
    "PrivateSubnet-EKS-B",
    "PrivateSubnet-DB-A",
    "PrivateSubnet-DB-B"
  ]

#  tgw_subnets      = ["10.0.31.0/28", "10.0.32.0/28"]
  tgw_subnets      = ["10.222.31.0/28", "10.222.32.0/28"]
  tgw_subnet_names = ["KOR-TGW-SubnetA", "KOR-TGW-SubnetB"]

  key_name      = var.key_name_kor
  admin_cidr    = var.admin_cidr
  tgw_id        = aws_ec2_transit_gateway.kor.id
#  peer_vpc_cidr = "10.1.0.0/16" 
  peer_vpc_cidr = "10.223.0.0/16" 
}

module "usa_vpc" {
  source    = "../vpc"
  providers = { aws = aws.oregon }
  onprem_private_cidr = var.onprem_private_cidr

#  name = "USA-Primary-VPC"
  name = "chan-USA-Primary-VPC"
#  cidr = "10.1.0.0/16"
  cidr = "10.223.0.0/16"
  azs  = ["us-west-2a", "us-west-2b"]

#  public_subnets      = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets      = ["10.223.1.0/24", "10.223.2.0/24"]
  public_subnet_names = ["PublicSubnet-A", "PublicSubnet-B"]
/*
  private_subnets = [
    "10.1.11.0/24",
    "10.1.12.0/24",
    "10.1.21.0/24",
    "10.1.22.0/24"
  ]
*/
  private_subnets = [
    "10.223.11.0/24",
    "10.223.12.0/24",
    "10.223.21.0/24",
    "10.223.22.0/24"
  ]
  private_subnet_names = [
    "PrivateSubnet-EKS-A",
    "PrivateSubnet-EKS-B",
    "PrivateSubnet-DB-A",
    "PrivateSubnet-DB-B"
  ]

#  tgw_subnets      = ["10.1.31.0/28", "10.1.32.0/28"]
  tgw_subnets      = ["10.223.31.0/28", "10.223.32.0/28"]
  tgw_subnet_names = ["USA-TGW-SubnetA", "USA-TGW-SubnetB"]

  key_name      = var.key_name_usa
  admin_cidr    = var.admin_cidr
  tgw_id        = aws_ec2_transit_gateway.usa.id
#  peer_vpc_cidr = "10.0.0.0/16"
  peer_vpc_cidr = "10.222.0.0/16"
}

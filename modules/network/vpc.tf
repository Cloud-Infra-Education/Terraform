module "kor_vpc" {
  source    = "../vpc"
  providers = { aws = aws.seoul }

  name = "y2om-KOR-Primary-VPC"
  cidr = "10.23.0.0/16"
  azs  = ["ap-northeast-2a", "ap-northeast-2b"]

  public_subnets      = ["10.23.1.0/24", "10.23.2.0/24"]
  public_subnet_names = ["y2om-PublicSubnet-A", "y2om-PublicSubnet-B"]

  private_subnets = [
    "10.23.11.0/24",
    "10.23.12.0/24",
    "10.23.21.0/24",
    "10.23.22.0/24"
  ]

  private_subnet_names = [
    "y2om-PrivateSubnet-EKS-A",
    "y2om-PrivateSubnet-EKS-B",
    "y2om-PrivateSubnet-DB-A",
    "y2om-PrivateSubnet-DB-B"
  ]

  tgw_subnets      = ["10.23.31.0/28", "10.23.32.0/28"]
  tgw_subnet_names = ["y2om-KOR-TGW-SubnetA", "y2om-KOR-TGW-SubnetB"]

  key_name      = var.key_name_kor
  admin_cidr    = var.admin_cidr
  tgw_id        = aws_ec2_transit_gateway.kor.id
  peer_vpc_cidr = "10.24.0.0/16"
}

module "usa_vpc" {
  source    = "../vpc"
  providers = { aws = aws.oregon }

  name = "y2om-USA-Primary-VPC"
  cidr = "10.24.0.0/16"
  azs  = ["us-west-2a", "us-west-2b"]

  public_subnets      = ["10.24.1.0/24", "10.24.2.0/24"]
  public_subnet_names = ["y2om-PublicSubnet-A", "y2om-PublicSubnet-B"]

  private_subnets = [
    "10.24.11.0/24",
    "10.24.12.0/24",
    "10.24.21.0/24",
    "10.24.22.0/24"
  ]

  private_subnet_names = [
    "y2om-PrivateSubnet-EKS-A",
    "y2om-PrivateSubnet-EKS-B",
    "y2om-PrivateSubnet-DB-A",
    "y2om-PrivateSubnet-DB-B"
  ]

  tgw_subnets      = ["10.24.31.0/28", "10.24.32.0/28"]
  tgw_subnet_names = ["y2om-USA-TGW-SubnetA", "y2om-USA-TGW-SubnetB"]

  key_name      = var.key_name_usa
  admin_cidr    = var.admin_cidr
  tgw_id        = aws_ec2_transit_gateway.usa.id
  peer_vpc_cidr = "10.23.0.0/16"
}

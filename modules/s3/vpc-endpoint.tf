# S3용 VPC Gateway 엔드포인트
# Lambda 함수가 VPC 내에서 S3에 빠르게 접근할 수 있도록 함
# vpc_id가 제공될 때만 생성

resource "aws_vpc_endpoint" "s3" {
  # count를 제거하고 항상 생성 (vpc_id는 항상 값이 있음)
  # route_table_ids는 apply 후 업데이트될 수 있음
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = var.private_route_table_ids

  tags = {
    Name = "${var.our_team}-s3-gateway-endpoint"
  }
}

data "aws_region" "current" {}

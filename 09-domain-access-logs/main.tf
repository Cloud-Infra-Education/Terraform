# 기본 provider (Lambda, OpenSearch 등)
provider "aws" {
  region = var.aws_region
}

# Route53 Query Logging용 CloudWatch Logs는 us-east-1에 생성해야 함
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
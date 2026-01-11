provider "aws" {
  region = "ap-northeast-2"
}

provider "aws" {
  region = "ap-northeast-2"
  alias  = "seoul"
}

provider "aws" {
  region = "us-west-2"
  alias  = "oregon"
}

# ACM(CloudFront용)은 us-east-1
provider "aws" {
  region = "us-east-1"
  alias  = "acm"
}

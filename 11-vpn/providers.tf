provider "aws" {
  region = "ap-northeast-2"
}

provider "aws" {
  region = "ap-northeast-2"
  alias  = "seoul"
}


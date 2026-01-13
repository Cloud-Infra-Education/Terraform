# AWS Providers
provider "aws" {
  region = "ap-northeast-2"
}

provider "aws" {
  region = "ap-northeast-2"
  alias  = "seoul"
}

provider "aws" {
  region = "us-west-2"
  alias  = "oregon" # <--- 이 부분이 없으면 에러가 납니다
}

provider "aws" {
  region = "us-east-1"
  alias  = "acm"
}

# ====================
# Kubernetes providers
# ====================

# 서울 클러스터 접속 설정
provider "kubernetes" {
  alias                  = "seoul"
  host                   = data.terraform_remote_state.kubernetes.outputs.seoul_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.kubernetes.outputs.seoul_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name,
      "--region", "ap-northeast-2"
    ]
  }
}

# 오레곤 클러스터 접속 설정
provider "kubernetes" {
  alias                  = "oregon"
  host                   = data.terraform_remote_state.kubernetes.outputs.oregon_cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.kubernetes.outputs.oregon_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", data.terraform_remote_state.kubernetes.outputs.oregon_cluster_name,
      "--region", "us-west-2"
    ]
  }
}

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

# ============================================================
# Kubernetes Provider 설정 (ConfigMap 생성을 위해)
# ============================================================

# EKS 클러스터 정보 가져오기
data "aws_eks_cluster" "seoul" {
  name     = data.terraform_remote_state.kubernetes.outputs.seoul_cluster_name
  provider = aws.seoul
}

# Kubernetes Provider 설정
provider "kubernetes" {
  alias = "seoul"
  
  host                   = data.aws_eks_cluster.seoul.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.seoul.certificate_authority[0].data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.seoul.name,
      "--region",
      "ap-northeast-2"
    ]
  }
}

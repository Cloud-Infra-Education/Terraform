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

# Kubernetes providers (required by domain module)
provider "kubernetes" {
  host                   = module.eks.seoul_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.seoul_cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.seoul_cluster_name,
      "--region",
      "ap-northeast-2"
    ]
  }
}

provider "kubernetes" {
  alias                  = "oregon"
  host                   = module.eks.oregon_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.oregon_cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.oregon_cluster_name,
      "--region",
      "us-west-2"
    ]
  }
}

# Helm providers (required by addons and argocd modules)
# Helm provider 3.0+ requires kubernetes as nested object, not block
provider "helm" {
  kubernetes = {
    host                   = module.eks.seoul_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.seoul_cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", "get-token",
        "--cluster-name", module.eks.seoul_cluster_name,
        "--region", "ap-northeast-2"
      ]
    }
  }
}

provider "helm" {
  alias = "oregon"

  kubernetes = {
    host                   = module.eks.oregon_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.oregon_cluster_certificate_authority_data)

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", "get-token",
        "--cluster-name", module.eks.oregon_cluster_name,
        "--region", "us-west-2"
      ]
    }
  }
}

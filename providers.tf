terraform {
  required_version = ">= 1.5.0"

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    time = {
      source = "hashicorp/time"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }

  }

}

#default provider 참조하는 경우
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


# Seoul
provider "kubernetes" {
  host                   = module.eks_seoul.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_seoul.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", module.eks_seoul.cluster_name,
      "--region", "ap-northeast-2"
    ]
  }
}

# Oregon
provider "kubernetes" {
  alias                  = "oregon"
  host                   = module.eks_oregon.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_oregon.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", module.eks_oregon.cluster_name,
      "--region", "us-west-2"
    ]
  }
}

# Seoul Helm
provider "helm" {
  kubernetes {
    host                   = module.eks_seoul.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_seoul.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", "get-token",
        "--cluster-name", module.eks_seoul.cluster_name,
        "--region", "ap-northeast-2"
      ]
    }
  }
}

# Oregon Helm
provider "helm" {
  alias = "oregon"

  kubernetes {
    host                   = module.eks_oregon.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks_oregon.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks", "get-token",
        "--cluster-name", module.eks_oregon.cluster_name,
        "--region", "us-west-2"
      ]
    }
  }
}


terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~> 0.10"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

# Default provider (Seoul). Keep for resources/modules that don't specify alias.
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

# -----------------------
# Kubernetes providers
# -----------------------

# Seoul
provider "kubernetes" {
  host                   = module.eks.seoul_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.seoul_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", module.eks.seoul_cluster_name,
      "--region", "ap-northeast-2"
    ]
  }
}

# Oregon
provider "kubernetes" {
  alias                  = "oregon"
  host                   = module.eks.oregon_cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.oregon_cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks", "get-token",
      "--cluster-name", module.eks.oregon_cluster_name,
      "--region", "us-west-2"
    ]
  }
}

# -----------------------
# Helm providers
# -----------------------

# Seoul Helm
provider "helm" {
  kubernetes {
    host                   = module.eks.seoul_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.seoul_cluster_certificate_authority_data)

    exec {
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

# Oregon Helm
provider "helm" {
  alias = "oregon"

  kubernetes {
    host                   = module.eks.oregon_cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.oregon_cluster_certificate_authority_data)

    exec {
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

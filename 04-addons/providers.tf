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

# ====================
# Kubernetes providers
# ====================
provider "kubernetes" {
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

# ==============
# Helm providers
# ==============
provider "helm" {
  kubernetes {
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
}

provider "helm" {
  alias = "oregon"

  kubernetes {
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
}

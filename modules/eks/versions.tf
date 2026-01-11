terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.seoul, aws.oregon]
    }
    helm = {
      source                = "hashicorp/helm"
      configuration_aliases = [helm.oregon]
    }
  }
}


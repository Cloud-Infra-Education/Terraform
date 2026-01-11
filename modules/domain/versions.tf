terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.seoul, aws.acm, aws.oregon]
    }
  }
}


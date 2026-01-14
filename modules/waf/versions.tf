terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      configuration_aliases = [aws.acm, aws.seoul, aws.oregon]
    }
  }
}


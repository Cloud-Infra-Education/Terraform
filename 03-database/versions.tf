terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    mysql = {
      source  = "petoju/mysql"
      version = "3.0.88"

    }
  }
}


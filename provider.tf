terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.13.0"   # pick a stable version
    }
  }

  required_version = "1.13.2"
}

provider "aws" {
  region = "us-east-1"   # change to your preferred AWS region
}

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider: Mumbai
provider "aws" {
  region  = "ap-south-1"
  profile = var.aws_profile
}

# Aliased provider: Virginia
provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  profile = var.aws_profile
}

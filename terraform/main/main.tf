terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
  }
}

provider "aws" {
  region = "us-west-2"
  default_tags {
    tags = {
      environment = var.environment
      terraform   = true
      project     = "model_elixir"
    }
  }
}

data "aws_caller_identity" "account" {}

# cloudfront requires things to be in us-east-1 and thus that is where we shall be

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  default_tags {
    tags = {
      environment = var.environment
      terraform   = true
      project     = "model_elixir"
    }
  }
}

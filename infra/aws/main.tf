terraform {
  required_version = "1.14.3"

  backend "s3" {
    region = "us-east-1"
    bucket = "personal-infra-states"
    key    = "portfolio/aws"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
  }
}
provider "aws" {
  alias = "ap-southeast-2"

  region = "ap-southeast-2"

  default_tags {
    tags = local.tags
  }
}

data "terraform_remote_state" "shared_infra_aws" {
  backend = "s3"
  config = {
    region = "us-east-1"
    bucket = "personal-infra-states"
    key    = "shared-infra/aws"
  }
}

data "aws_caller_identity" "current" {}

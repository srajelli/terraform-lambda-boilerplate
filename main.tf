terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

locals {
  region    = "ap-southeast-1"
  accountId = ""
}
provider "aws" {
  region = locals.region
}

module "apiGateway" {
  source      = "./modules/gateway"
  name        = "api"
  description = "terraform lambda example"
}



terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      team        = "platform"
      environment = "test"
      repo-link   = "https://github.com/vyrwu/blockchain-gateway-demo"
      managed-by  = "terraform"
    }
  }
}

module "platform" {
  source         = "./modules/platform"
  region         = "eu-west-1"
  vpc_cidr_block = "10.0.0.0/16"
}

module "blockchain-gateway" {
  source       = "./modules/service"
  service_name = "blockchain-gateway"
  image_tag    = var.image_tag
  depends_on = [
    module.platform
  ]
}

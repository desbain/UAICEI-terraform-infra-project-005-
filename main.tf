provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "tfstate-remote-backend-005"
    key            = "jupiter/statefile"
    region         = "us-east-2"
    dynamodb_table = "jupiter-state-locking-005"
    encrypt        = true
  }
}

module "vpc" {
  source                    = "./vpc"
  vpc_cidr_block            = var.vpc_cidr_block
  tags                      = local.project_tags
  public_subnet_cidr_block  = var.public_subnet_cidr_block
  availability_zone         = var.availability_zone
  private_subnet_cidr_block = var.private_subnet_cidr_block
}
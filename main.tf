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
  db_cidr_block             = var.db_cidr_block

}

module "ec2" {
  source                 = "./ec2"
  vpc_id                 = module.vpc.vpc_id
  tags                   = local.project_tags
  public_subnet_id_az2a  = module.vpc.public_subnet_id_az2a
  key_name               = var.key_name
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  private_subnet_id_az2a = module.vpc.private_subnet_id_az2a
  private_subnet_id_az2b = module.vpc.private_subnet_id_az2b
}

module "alb" {
  source                = "./ALB"
  vpc_id                = module.vpc.vpc_id
  tags                  = local.project_tags
  public_subnet_id_az2a = module.vpc.public_subnet_id_az2a
  public_subnet_id_az2b = module.vpc.public_subnet_id_az2b
}

module "autoscaling" {
  source                = "./Autoscaling"
  vpc_id                = module.vpc.vpc_id
  tags                  = local.project_tags
  public_subnet_id_az2a = module.vpc.public_subnet_id_az2a
  public_subnet_id_az2b = module.vpc.public_subnet_id_az2b
  jupiter_app_tg_arn    = [module.alb.jupiter_app_tg_arn]
  max_size              = var.max_size
  min_size              = var.min_size
  desired_capacity      = var.desired_capacity
  instance_type         = var.instance_type
  ami_id                = var.ami_id
  key_name              = var.key_name
}
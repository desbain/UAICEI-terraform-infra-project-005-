provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket       = "tfstate-remote-backend-005"
    key          = "jupiter/statefile"
    region       = "us-east-2"
    use_lockfile = true
    encrypt      = true
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
  ssl_policy            = var.ssl_policy
  certificate_arn       = var.certificate_arn
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

module "route53" {
  source                  = "./route53"
  route53_zone_id         = var.route53_zone_id
  name                    = var.name
  jupiter_app_lb_dns_name = module.alb.jupiter_app_lb_dns_name
  alb_zone_id             = module.alb.alb_zone_id
}

import {
  to = module.route53.aws_route53_record.dns_record
  id = "${var.route53_zone_id}_${var.name}_A"
}

module "rds" {
  source                       = "./RDS"
  vpc_id                       = module.vpc.vpc_id
  tags                         = local.project_tags
  db_subnet_id_az2a            = module.vpc.db_subnet_id_az2a
  db_subnet_id_az2b            = module.vpc.db_subnet_id_az2b
  allocated_storage            = var.allocated_storage
  db_name                      = var.db_name
  engine                       = var.engine
  engine_version               = var.engine_version
  instance_class               = var.instance_class
  parameter_group_name         = var.parameter_group_name
  rds_secrets_manager_role_arn = module.iam.rds_secrets_manager_role_arn
}

module "iam" {
  source     = "./IAM"
  region     = var.region
  account_id = var.account_id
}
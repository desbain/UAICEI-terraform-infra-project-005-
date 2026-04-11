variable "vpc_id" {
  type = string
}

variable "tags" {
  description = "Tags for the VPC"
  type        = map(string)
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Key name for the EC2 instance"
  type        = string
}

variable "public_subnet_id_az2a" {
  description = "Public subnet ID for AZ2A"
  type        = string
}

variable "public_subnet_id_az2b" {
  description = "Public subnet ID for AZ2B"
  type        = string
}

variable "jupiter_app_tg_arn" {
  description = "Target group ARN for the Jupiter app"
  type        = list(string)
}

variable "max_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "desired_capacity" {
  type = number
}


variable "db_subnet_id_az2a" {
    type = string
}

variable "db_subnet_id_az2b" {
    type = string
}

variable "tags" {
    description = "Tags for the RDS"
    type = map(string)
}

variable "vpc_id" {
    type = string
}

variable "allocated_storage" {
    type = number
}

variable "db_name" {
  type = string
}

variable "engine" {
  type = string
}

variable "engine_version" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "parameter_group_name" {
  type = string
}

variable "rds_secrets_manager_role_arn" {
  type = string
}
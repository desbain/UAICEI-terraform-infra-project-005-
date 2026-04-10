variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "public_subnet_id_az2a" {
  type = string
}

variable "key_name" {
  type = string
}

variable "private_subnet_id_az2a" {
    type = string
}

variable "private_subnet_id_az2b" {
    type = string
}
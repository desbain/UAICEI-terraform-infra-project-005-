variable "vpc_id" {
  type = string
}

variable "tags" {
  description = "Tags for the VPC"
  type        = map(string)
}

variable "public_subnet_id_az2a" {
  description = "Public subnet ID for AZ2A"
  type        = string
}

variable "public_subnet_id_az2b" {
  description = "Public subnet ID for AZ2B"
  type        = string
}

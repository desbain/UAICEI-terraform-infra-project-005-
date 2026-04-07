variable "vpc_cidr_block" {
    description = "CIDR block for VPC"
    type = string
}

variable "tags" {
    description = "Tags for the VPC"
    type = map(string)
}

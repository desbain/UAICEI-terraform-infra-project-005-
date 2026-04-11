vpc_cidr_block = "10.0.0.0/16"
tags = {
  Environment = "Dev"
}
public_subnet_cidr_block  = ["10.0.0.0/24", "10.0.1.0/24"]
availability_zone         = ["us-east-2a", "us-east-2b"]
private_subnet_cidr_block = ["10.0.2.0/24", "10.0.3.0/24"]
db_cidr_block             = ["10.0.4.0/24", "10.0.5.0/24"]
ami_id                    = "ami-051de6a4e7ae45f77"
instance_type             = "t3.micro"
key_name                  = "jupiter360keys"
max_size                  = 5
min_size                  = 2
desired_capacity          = 4
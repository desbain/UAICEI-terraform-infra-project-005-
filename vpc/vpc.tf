resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-main-vpc"
  })
}

#CREATING INTERNET GATEWAY

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-igw"
  })
}


#CREATING PUBLIC SUBNET -----------------------------------------------------------------

resource "aws_subnet" "public_subnet_az2a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[0]
  availability_zone =var.availability_zone[0] 

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az2a"
  })

}

resource "aws_subnet" "public_subnet_az2b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr_block[1]
  availability_zone =var.availability_zone[1] 

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-subnet-az2b"
  })

}

# CREATING PRIVATE SUBNET -----------------------------------------------------------------

resource "aws_subnet" "private_subnet_az2a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[0]
  availability_zone =var.availability_zone[0] 

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az2a"
  })

}

resource "aws_subnet" "private_subnet_az2b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr_block[1]
  availability_zone =var.availability_zone[1] 

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-subnet-az2b"
  })

}

# CREATING DATABASE SUBNET -----------------------------------------------------------------

resource "aws_subnet" "db_subnet_az2a" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_cidr_block[0]
  availability_zone =var.availability_zone[0] 

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az2a"
  })

}

resource "aws_subnet" "db_subnet_az2b" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.db_cidr_block[1]
  availability_zone =var.availability_zone[1] 

tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-az2b"
  })

}

# CREATING PUBLIC ROUTE TABLE

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-public-rt"
  }
}

#CREATING SUBNET ROUTE TABLE ASSOCIATION -------------------------
resource "aws_route_table_association" "assoc_public_subnet_az2a" {
  subnet_id      = aws_subnet.public_subnet_az2a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "assoc_public_subnet_az2b" {
  subnet_id      = aws_subnet.public_subnet_az2b.id
  route_table_id = aws_route_table.public_rt.id
}

#CREATING AN ELASTIC IP FOR NAT GATEWAY
resource "aws_eip" "eip_az_2a" {
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-2a"
  })
}

#CREATING A NAT GATEWAY ---------------------------------------------------
resource "aws_nat_gateway" "nat_gw_az_2a" {
  allocation_id = aws_eip.eip_az_2a.id
  subnet_id     = aws_subnet.public_subnet_az2a.id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-2a"
  })


  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_2a, aws_subnet.public_subnet_az2a]
}

#CREATING PRIVATE ROUTE TABLE IN AZ 2A-----------------------------------------------------------------

resource "aws_route_table" "private_rt_az2a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az_2a.id
  }

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt"
  }
}
 
#CREATING PRIVATE ROUTE TABLE ASSOCIATION IN AZ 2A -----------------------------------

resource "aws_route_table_association" "assoc_private_subnet_az2a" {
  subnet_id      = aws_subnet.private_subnet_az2a.id
  route_table_id = aws_route_table.private_rt_az2a.id
}

resource "aws_route_table_association" "assoc_db_subnet_az2a" {
  subnet_id      = aws_subnet.db_subnet_az2a.id
  route_table_id = aws_route_table.private_rt_az2a.id
}

#CREATING AN ELASTIC IP FOR NAT GATEWAY IN AZ 2B
resource "aws_eip" "eip_az_2b" {
  domain   = "vpc"

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-eip-az-2b"
  })
}

#CREATING A NAT GATEWAY IN AZ 2B ---------------------------------------------------
resource "aws_nat_gateway" "nat_gw_az_2b" {
  allocation_id = aws_eip.eip_az_2b.id
  subnet_id     = aws_subnet.public_subnet_az2b.id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-nat-gw-az-2b"
  })


  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_eip.eip_az_2b, aws_subnet.public_subnet_az2b]
}

#CREATING PRIVATE ROUTE TABLE IN AZ 2B-----------------------------------------------------------------

resource "aws_route_table" "private_rt_az2b" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw_az_2b.id
  }

  tags = {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-private-rt-az2b"
  }
}
 
#CREATING PRIVATE ROUTE TABLE ASSOCIATION IN AZ 2B -----------------------------------

resource "aws_route_table_association" "assoc_private_subnet_az2b" {
  subnet_id      = aws_subnet.private_subnet_az2b.id
  route_table_id = aws_route_table.private_rt_az2b.id
}

resource "aws_route_table_association" "assoc_db_subnet_az2b" {
  subnet_id      = aws_subnet.db_subnet_az2b.id
  route_table_id = aws_route_table.private_rt_az2b.id
}

output "vpc_id" {
    value  = aws_vpc.main_vpc.id
}

output "public_subnet_id_az2a" {
    value = aws_subnet.public_subnet_az2a.id
}

output "public_subnet_id_az2b" {
    value = aws_subnet.public_subnet_az2b.id
}

output "private_subnet_id_az2a" {
    value = aws_subnet.private_subnet_az2a.id
}

output "private_subnet_id_az2b" {
    value = aws_subnet.private_subnet_az2b.id
}

output "db_subnet_id_az2a" {
    value = aws_subnet.db_subnet_az2a.id
}

output "db_subnet_id_az2b" {
    value = aws_subnet.db_subnet_az2b.id
}


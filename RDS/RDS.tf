# CREATING A DATABASE SUBNET GROUP

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db_subnet_group"
  subnet_ids = [var.db_subnet_id_az2a, var.db_subnet_id_az2b]

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-db-subnet-group"
  })

}

# CREATING RDS SECURITY GROUP

resource "aws_security_group" "rds_server_sg" {
  name        = "rds-server-sg"
  description = "Allow DB Traffic"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-rds-server-sg"
  })
}

#CREATING INBOUND RULES
resource "aws_vpc_security_group_ingress_rule" "allow_DB_traffic" {
  security_group_id = aws_security_group.rds_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}


#CREATING OUTBOUND RULES FOR RDS SECURITY GROUP
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.rds_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING MYSQL RDS 
data "aws_secretsmanager_secret" "rds_db_secret" {
  name = "jupiter_db_credentials" # name of the secret in secrets manager
}

data "aws_secretsmanager_secret_version" "rds_db_secret_value" {
  secret_id = data.aws_secretsmanager_secret.rds_db_secret.id
}

# CREATING MYSQL RDS INSTANCE

resource "aws_db_instance" "rds_mysql" {
  allocated_storage                   = var.allocated_storage
  db_name                             = var.db_name
  engine                              = var.engine
  engine_version                      = var.engine_version
  instance_class                      = var.instance_class
  username                            = jsondecode(data.aws_secretsmanager_secret_version.rds_db_secret_value.secret_string)["mysql_username"]
  password                            = jsondecode(data.aws_secretsmanager_secret_version.rds_db_secret_value.secret_string)["mysql_password"]
  parameter_group_name                = var.parameter_group_name
  skip_final_snapshot                 = true
  multi_az                            = true
  publicly_accessible                 = false
  storage_type                        = "gp2"
  db_subnet_group_name                = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids              = [aws_security_group.rds_server_sg.id]
  iam_database_authentication_enabled = true

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-rds-mysql"
  })

}

resource "aws_db_instance_role_association" "rds_secrets_manager_role" {
  db_instance_identifier = aws_db_instance.rds_mysql.id
  feature_name           = "secretsManager"
  role_arn               = var.rds_secrets_manager_role_arn
}
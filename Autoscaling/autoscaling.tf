# CREATING A SECURITY GROUP FOR THE AUTOSCALING GROUP

resource "aws_security_group" "jupiter_server_sg" {
  name        = "jupiter-server-sg"
  description = "Allow SSH Traffic"
  vpc_id      = var.vpc_id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupiter-server-sg"
  })
}

#CREATING INBOUND RULES
resource "aws_vpc_security_group_ingress_rule" "allow_SSH_jupiter" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_jupiter" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#CREATING OUTBOUND RULES
resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS_jupiter" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}


resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4_jupiter" {
  security_group_id = aws_security_group.jupiter_server_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# CREATING A LAUNCH TEMPLATE FOR THE AUTOSCALING GROUP

resource "aws_launch_template" "jupiter_server_launch_template" {
  name_prefix   = "jupiter-server-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = base64encode(file("Scripts/Jupiter-app-deployment.sh"))

network_interfaces {
  associate_public_ip_address = true
  security_groups             = [aws_security_group.jupiter_server_sg.id]
}
  
}

# CREATING AUTOSCALING GROUP ------------------------------------------------
resource "aws_autoscaling_group" "jupiter-app-asg" {
  name                      = "jupiter-app-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.desired_capacity
  force_delete              = true
  vpc_zone_identifier       = [var.public_subnet_id_az2a, var.public_subnet_id_az2b]
  target_group_arns         = var.jupiter_app_tg_arn
  launch_template {
    id      = aws_launch_template.jupiter_server_launch_template.id
    version = "$Latest"
  }

}



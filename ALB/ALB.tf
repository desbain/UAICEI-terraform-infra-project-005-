# CREATING A LOAD BALANCER SECURITY GROUP FOR THE ALB

resource "aws_security_group" "jupiter_alb_sg" {
  name        = "jupiter-alb-sg"
  description = "Allow SSH Traffic"
  vpc_id      = var.vpc_id

   tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupiter-alb-sg"
  })
}

#CREATING INBOUND RULES
resource "aws_vpc_security_group_ingress_rule" "allow_SSH_jupiter_alb" {
  security_group_id = aws_security_group.jupiter_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_HTTP_jupiter_alb" {
  security_group_id = aws_security_group.jupiter_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

#CREATING OUTBOUND RULES
resource "aws_vpc_security_group_ingress_rule" "allow_HTTPS_jupiter_alb" {
  security_group_id = aws_security_group.jupiter_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# CREATING A TARGET GROUP FOR THE AUTOSCALING GROUP----------------------------------------------
resource "aws_lb_target_group" "Jupiter-app-tg" {
  name     = "Jupiter-app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 5
    interval            = 30
    matcher             = "200,301,302"
    path                = "/"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

# CREATING APPLICATION LOAD BALANCER ----------------------------------------

resource "aws_lb" "jupiter_app_lb" {
  name               = "jupiter-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.jupiter_alb_sg.id]
  subnets            = [var.public_subnet_id_az2a, var.public_subnet_id_az2b]

  enable_deletion_protection = false

 # access_logs {
   # bucket  = aws_s3_bucket.lb_logs.id
    #prefix  = "test-lb"
    #enabled = true
  #}

  tags = merge(var.tags, {
    Name = "${var.tags["project"]}-${var.tags["application"]}-${var.tags["environment"]}-jupiter-alb"
  })
}

# CREATING A LISTENER FOR THE LOAD BALANCER ----------------------------------------

resource "aws_lb_listener" "jupiter_app_alb_listener" {
  load_balancer_arn = aws_lb.jupiter_app_lb.arn
  port                = 80
  protocol            = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Jupiter-app-tg.arn
  }
}

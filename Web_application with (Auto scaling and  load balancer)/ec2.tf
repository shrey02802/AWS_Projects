# Security group for ALB

resource "random_id" "alb" {
  byte_length = 4
}

resource "aws_security_group" "alb_security_g" {
  name        = "alb-${random_id.alb.hex}"
  description = "Security group for appplication load balancer"
  vpc_id      = aws_vpc.custom_vpc.id

  tags = {
    Name = "ALB_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_ingress" {
  security_group_id = aws_security_group.alb_security_g.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb_security_g.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# Security group for EC2

resource "aws_security_group" "ec2" {
  name        = "alb"
  description = "Security group for web server"
  vpc_id      = aws_vpc.custom_vpc.id

  tags = {
    Name = "ec2"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ec2_ingress" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 0
  ip_protocol       = "-1"
  to_port           = 0
}

resource "aws_vpc_security_group_egress_rule" "ec2_egress" {
  security_group_id = aws_security_group.ec2.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Application load balancer

resource "aws_lb" "ALB" {
  name               = "ALBEC2"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_security_g.id]
  subnets            = aws_subnet.public_subnet[*].id
  depends_on         = [aws_internet_gateway.internet_gateway]

  tags = {
    name = "ALB"
  }
}

resource "aws_lb_target_group" "ALB_EC2" {
  name     = "ALBTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id
}



# Application load balancer listner

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.ALB.id
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ALB_EC2.arn
  }
}

#launch ec2
resource "aws_launch_template" "ec2_web_server" {
  name_prefix   = "web"
  image_id      = "ami-0953476d60561c955"
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.ec2.id]
  }
   
   user_data = filebase64("userdata.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "web" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = aws_subnet.public_subnet[*].id  # List of subnet IDs

  launch_template {
    id      = aws_launch_template.ec2_web_server.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "WebServer"
    propagate_at_launch = true
  }

  health_check_type = "EC2"
  force_delete      = true
}


output "alb_dns_name" {
  value = aws_lb.ALB.dns_name
}
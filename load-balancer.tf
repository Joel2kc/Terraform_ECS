resource "aws_alb" "alb" {
  name           = "myapp-load-balancer"
  subnets        = [aws_subnet.public-subnet.id,aws_subnet.private-subnet.id]
  security_groups = [aws_security_group.app-lb-sg.id]
  internal       = false
}

resource "aws_alb_target_group" "myapp-tg" {
  name_prefix = "ph"
  #name        = "myapp-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.terraform-vpc.id
  target_type = "ip"

  lifecycle {
    create_before_destroy = true
  }
 
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/"
    interval            = 30
  }
}

#redirecting all incomming traffic from ALB to the target group
resource "aws_alb_listener" "testapp" {
  load_balancer_arn = aws_alb.alb.arn
  port              = 80
  protocol          = "HTTP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  #enable above 2 if you are using HTTPS listner and change protocal from HTTPS to HTTPS
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.myapp-tg.arn
  }
} 

resource "aws_security_group" "app-lb-sg" {
  name        = "app-lb-sg"
  description = "Security group using terraform"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "app-lb-sg"
  }
}
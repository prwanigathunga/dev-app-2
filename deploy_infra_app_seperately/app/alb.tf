resource "aws_lb" "main_lb" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-0ac0ad24e17401d9d", "subnet-0e942f31c5c6b383e"]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "main_lb_tg" {
  name     = "main-tg"
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = "vpc-0d8357a04b30a5447"
  health_check {
    path                = "/api/student/getStudent"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main_lb_tg.arn
  }
}

resource "aws_security_group" "alb_sg" {
  vpc_id = "vpc-0d8357a04b30a5447"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

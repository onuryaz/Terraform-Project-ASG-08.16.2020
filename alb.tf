
# Create a data source for the availability zones.
data "aws_availability_zones" "all" {}

#Provision load balancer
resource "aws_lb" "alb" {
  name               = "public-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnets.0.id, aws_subnet.public_subnets.1.id, aws_subnet.public_subnets.2.id]

  enable_deletion_protection = true
  tags = {
    Environment = var.env_name
  }
}

#######################################
#######  target group ##################

resource "aws_lb_target_group" "my-target-group" {
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  name        = "my-test-tg"
  port        = 80
  protocol    = "HTTP"
 # target_type = "instance"
  vpc_id      = aws_vpc.main_vpc.id
}

resource "aws_lb_listener" "webserver_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my-target-group.arn
  }
}
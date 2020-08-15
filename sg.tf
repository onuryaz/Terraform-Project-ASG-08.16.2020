###  load balancer sec group #############
#########   port : 80 #####################

resource "aws_security_group" "alb_sg" {
  name = "sec_elb"
  vpc_id      = "${aws_vpc.main_vpc.id}"
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############### instance security group ########
################################################

resource "aws_security_group" "sec_webserver" {
  name        = "sec_web"
  vpc_id      = aws_vpc.main_vpc.id

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
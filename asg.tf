resource "aws_launch_configuration" "launch_config" {
  name_prefix                 = "terraform-example-web-instance"
  image_id                    = "${lookup(var.AMIS, var.region_name)}"
  instance_type               = var.web_instance
  iam_instance_profile        = aws_iam_instance_profile.ec2-iam-profile.id  ###  ec2 profile for s3 bucket
  associate_public_ip_address = false
  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y apache
              sudo service httpd start
              sudo chkconfig httpd on
              EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling_group" {
  launch_configuration = aws_launch_configuration.launch_config.id
  desired_capacity   = 2
  min_size             = var.autoscaling_group_min_size
  max_size             = var.autoscaling_group_max_size
  target_group_arns    = [aws_lb_target_group.my-target-group.arn]
  vpc_zone_identifier = [aws_subnet.frontend_subnets.0.id, aws_subnet.frontend_subnets.1.id, aws_subnet.frontend_subnets.2.id]
}



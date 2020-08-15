
# Create a subnet group with all of our RDS subnets. The group will be applied to the database instance.  
resource "aws_db_subnet_group" "default" {
  name        = "rds-subnet-group"
  subnet_ids  = [aws_subnet.db_subnets.0.id, aws_subnet.db_subnets.1.id, aws_subnet.db_subnets.2.id]
}

# Create a RDS security group in the VPC which our database will belong to.
resource "aws_security_group" "rds" {
  name        = "terraform_rds_security_group"
  description = "Terraform example RDS MySQL server"
  vpc_id      = "${aws_vpc.main_vpc.id}"

  # Keep the instance private by only allowing traffic from the web server.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"


    security_groups = ["${aws_security_group.sec_webserver.id}"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-rds-security-group"
  }
}

# Create a RDS MySQL database instance in the VPC with our RDS subnet group and security group.
resource "aws_db_instance" "default" {
#  identifier                = "${var.rds_instance_identifier}"
  allocated_storage         = 5
  engine                    = "mysql"
  engine_version            = "5.6.35"
  instance_class            = "db.t2.micro"
  name                      = var.database_name
  username                  = var.db_user
  password                  = var.db_password
  db_subnet_group_name      = "${aws_db_subnet_group.default.id}"
  vpc_security_group_ids    = ["${aws_security_group.rds.id}"]
  skip_final_snapshot       = true
  final_snapshot_identifier = "Ignore"
}

# Manage the MySQL configuration by creating a parameter group.
resource "aws_db_parameter_group" "default" {
  name        = "instance-param-group"
  family      = "mysql5.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }
}
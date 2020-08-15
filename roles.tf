
# this role policy give s3 access to role will be attached to role 

resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = aws_iam_role.test_role.id

  policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "s3:*"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "test_role" {
  name = "ec2_role"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

# when we launch ec2 instance we will use instance profile with the role so app retrieves role credentials
# from the instance reach to s3 bucket using role credentials 
resource "aws_iam_instance_profile" "ec2-iam-profile" {
    lifecycle {
     create_before_destroy = false
  }
    name = "s3-ec2-profile"
    role = aws_iam_role.test_role.name
}
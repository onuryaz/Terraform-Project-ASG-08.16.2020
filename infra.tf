resource "aws_vpc" "main_vpc" {
  cidr_block = "${var.cidr_base}.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "${var.env_name}-vpc"

  }
}

# public subnet load balancer will be located in this subnet 
resource "aws_subnet" "public_subnets" {
  count             = 3
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${var.cidr_base}.${ 10 + count.index }.0/24"
  availability_zone = "${var.region_name}${element(var.zones,  count.index)}"
}


# app servers located in this subnet
resource "aws_subnet" "frontend_subnets" {
  count             = 3
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${var.cidr_base}.${ 20 + count.index }.0/24"
  availability_zone = "${var.region_name}${element(var.zones,  count.index)}"
}

# database located in this subnet
resource "aws_subnet" "db_subnets" {
  count             = 3
  vpc_id            = "${aws_vpc.main_vpc.id}"
  cidr_block        = "${var.cidr_base}.${ 30 + count.index }.0/24"
  availability_zone = "${var.region_name}${element(var.zones,  count.index)}"
}


# go out of network using internet gateway 
resource "aws_route_table_association" "subnets_associate_front" {
  count          = 3
  subnet_id      = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route.id}"
  depends_on     = ["aws_route_table.public_route", "aws_subnet.public_subnets"]
}

# Associate Private Subnet with Private Route Table # for frontend subnet instances
resource "aws_route_table_association" "private_subnet_front" {
  count          = 3
  route_table_id = "${aws_default_route_table.private_route.id}"
  subnet_id      = "${aws_subnet.frontend_subnets.*.id[count.index]}"
  depends_on     = ["aws_default_route_table.private_route", "aws_subnet.frontend_subnets"]
}

resource "aws_route_table_association" "private_subnet_db" {
  count          = 3
  route_table_id = "${aws_default_route_table.private_route.id}"
  subnet_id      = "${aws_subnet.db_subnets.*.id[count.index]}"
  depends_on     = ["aws_default_route_table.private_route", "aws_subnet.db_subnets"]
}


# Internet gateway ##############################

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "My VPC - Internet Gateway"
  }
}

####################################################

# Public Route Table

resource "aws_route_table" "public_route" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.my_vpc_igw.id}"
  }

  tags = {
    Name = "my-test-public-route"
  }
}

# Private Route Table

resource "aws_default_route_table" "private_route" {
  default_route_table_id = "${aws_vpc.main_vpc.default_route_table_id}"

  route {
    nat_gateway_id = "${aws_nat_gateway.gw.id}"
    cidr_block     = "0.0.0.0/0"
  }

  tags = {
    Name = "my-private-route-table"
  }
}


####    nat gateway  ##################################################
#######  attached to private subnet for connecting to internet ########

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.my_ip.id
  subnet_id     = aws_subnet.frontend_subnets.0.id

  depends_on = [aws_internet_gateway.my_vpc_igw]
  
  tags = {
    Name = "gw NAT"
  }
}

 resource "aws_eip" "my_ip" {
  #  depends_on = [ "aws_internet_gateway.my_vpc_igw" ]
   vpc      = true
 }
resource "aws_vpc" "test-env" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "test-env"
  }
}

resource "aws_subnet" "subnet-uno" {
  map_public_ip_on_launch  = true
  cidr_block = "${cidrsubnet(aws_vpc.test-env.cidr_block, 3, 1)}"
  vpc_id = "${aws_vpc.test-env.id}"
  availability_zone = "us-west-2a"
}

//subnets.tf
resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.test-env.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }
tags = {
    Name = "test-env-route-table"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-uno.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}

resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.test-env.id}"
tags = {
    Name = "test-env-gw"
  }
}

resource "aws_security_group" "ingress-all-test" {
name = "allow-all-sg"
vpc_id = "${aws_vpc.test-env.id}"
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 22
    to_port = 22
    protocol = "tcp"
}
ingress {
  cidr_blocks = [
      "0.0.0.0/0"
    ]
  from_port = 8080
    to_port = 8080
    protocol = "tcp" 
}
ingress {
  cidr_blocks = [
      "0.0.0.0/0"
    ]
  from_port = 8000
    to_port = 8000
    protocol = "tcp" 
}

ingress {
  cidr_blocks = [
      "0.0.0.0/0"
    ]
  from_port = 8005
    to_port = 8005
    protocol = "tcp" 
}

ingress {
  cidr_blocks = [
      "0.0.0.0/0"
    ]
  from_port = 3000
    to_port = 3000
    protocol = "tcp" 
}

ingress {
  cidr_blocks = [
      "0.0.0.0/0"
    ]
  from_port = 9090
    to_port = 9090
    protocol = "tcp" 
}

// Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}

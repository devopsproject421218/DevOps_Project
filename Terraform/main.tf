terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

resource "aws_key_pair" "mykey" {
  key_name    = "mykey"
  public_key  = "${file("~/.ssh/github_key.pub")}"
}

resource "aws_instance" "vm-web" {
  ami           = "${var.ami_id}"
  instance_type = "${var.instance_type}"
  key_name = aws_key_pair.mykey.key_name
  security_groups = ["${aws_security_group.ingress-all-test.id}"]
 
  user_data = <<EOF
#! /bin/bash
sudo yum update -y
sudo yum install wget
sudo amazon-linux-extras install java-openjdk11
sudo amazon-linux-extras install epel -y
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum install jenkins -y
sudo service jenkins start
sudo chkconfig jenkins on
sudo amazon-linux-extras install docker
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker jenkins
sudo chkconfig docker on
sudo yum install git -y

EOF
  subnet_id = "${aws_subnet.subnet-uno.id}"
   tags = {
    Name = "server for Test"
    Env = "dev"
  }
}

resource "aws_eip" "lb" {
  instance = aws_instance.vm-web.id
  vpc      = true
}

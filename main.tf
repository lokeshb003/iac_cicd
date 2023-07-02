terraform {
  required_providers {
    aws = {
      source="hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "ec2_instance-1" {
  ami = "ami-053b0d53c279acc90"
  instance_type = "t2.micro"
  user_data = <<-EOL
  #!/bin/bash
  apt update
  apt install openjdk-11-jdk -y
  wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
  echo "deb https://pkg.jenkins.io/debian binary/" >> /etc/apt/sources.list
  apt update
  apt install jenkins -y
  systemctl status jenkins
  EOL

  tags = {
    Name = "jenkins-instance"
  }
}
resource "aws_vpc" "vpc-ec2" {
  cidr_block = "10.0.0.0/16"
}
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
  ami = "ami-0e820afa569e84cc1"
  instance_type = "t2.micro"
  tags = {
    Name = "lokiinstance"
  }
}
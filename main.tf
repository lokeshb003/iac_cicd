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
resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh-key-pair" {
  key_name = "ssh-key"
  public_key = tls_private_key.pk.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./privkey.pem"
  }
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

  key_name = aws_key_pair.ssh-key-pair.key_name


  tags = {
    Name = "jenkins-instance"
  }
}
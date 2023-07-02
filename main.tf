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
resource "aws_vpc" "vpc-ec2" {
  cidr_block = "10.5.5.0/16"
}

resource "aws_subnet" "jenkins_subnet" {
  vpc_id = aws_vpc.vpc-ec2.id
}

resource "aws_key_pair" "ssh-key-pair" {
  key_name = "ssh-key-pair-1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbtT16wurdu2V0JGbvx3nXM0RDf+e4FOxjqO/mJj4EVextBgY452N6r8npUpkKvCh0O9lHk1D/qk0f5tZ8QwyFZMAjfpQsSJiY+e8sSOpDRaJAqMooY4+IjdsLtHf65ci5EdN233kux+RAC45O1XzohPx+sfRD5UX/cqenZSHaO2PU2gVDPXQx+DARUxtx975cWtrOTyjlUI3mCOj1PzBrwnthCKCgr3xW3duLBiC40+Pot2aSMhMjMyCOLxaVPBjMbMW5W6SdLK1+K3jcRbqNvgAyZXEeJeRrdvBq6kfAQBUHjxHV12eDndgb1vjdRzjH7aZZT53smR9tjfEJR8g289UAUlbWSXBpqG7n0JBlEEGebLgBhcH88CFY8VGsV2W1SBGiXkZtZlgNAcQvn2YH4mj9sOQlvHc0ElEFSUi988qFR7nB98l8qdtFdNwISygI2ponXceOICW/9GJJe47PjLxsF/AG77B1UHWqbddQ+Nuuq1eCA3dTa3DD4Af6onA91TlbSwIaKzpZTe8oOwffcRHG9SO0imjmNryBwTp/qHvDRFe7iK9ruzJXYlZ4u0a0TyrXUnN890N1CU6pEYoouUHHqAkdrDs3JFwRENLcxR1vf9RMcdedHRf4FNqfCvh1jbRF3oLXg7lQ3KE6TvzFgVbL62vsEd+Qzu8uqMcyMQ== lokes@Lokesh"
}
resource "aws_network_interface" "net-interface" {
  subnet_id = aws_subnet.jenkins_subnet.id
  private_ips = ["10.5.5.100"]
  tags = {
    Name = "jenkins_network_interface"
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

  network_interface {
    network_interface_id = aws_network_interface.net-interface.id
    device_index = 0
  }


  tags = {
    Name = "jenkins-instance"
  }
}
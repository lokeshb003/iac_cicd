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
  #!/bin/bash -xe

  apt update && apt install curl wget -y
  curl -X POST https://circleci.com/api/v2/project/github/lokeshb003/Petclinic/pipeline --header "Circle-Token: CCIPAT_8Gav5rGKQGAbcZhCPexwdM_b959eea4d7a9c45aa888987221985010f84226fa" --header "content-type: application/json" --data '{"branch":"circleci-project-setup"}'
  sleep 200s
  cd /root && wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.0-M9/bin/apache-tomcat-11.0.0-M9.tar.gz && mkdir /opt/tomcat && tar xvzf apache-tomcat-11.0.0-M9.tar.gz --strip-components 1 --directory /opt/tomcat
  curl -u "lokeshbalaji2021@gmail.com:Reva@12345678" -L -O 'https://lokeshbalaji003.jfrog.io/artifactory/springboot-app-libs-snapshot/target/petclinic.war'
  cp petclinic.war /opt/tomcat/webapps/
  bash /opt/tomcat/bin/startup.sh
  EOL

  key_name = aws_key_pair.ssh-key-pair.key_name


  tags = {
    Name = "tomcat-server"
  }
}
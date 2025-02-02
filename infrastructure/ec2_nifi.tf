resource "random_pet" "sg" {}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {

  ami                    = "ami-00beae93a2d981137"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.web-sg.id]

  tags = {
    Name = "nifi"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update
              sudo yum install docker
              sudo usermod -a -G docker ec2-user
              id ec2-user
              newgrp docker
              sudo systemctl enable docker.service
              sudo systemctl start docker.service
              docker run --name nifi \
                -p 8443:8443 \
                -d \
                -e SINGLE_USER_CREDENTIALS_USERNAME=admin \
                -e SINGLE_USER_CREDENTIALS_PASSWORD=secretpassword \
                apache/nifi:latest
              EOF

  user_data_replace_on_change = true

#   user_data = <<-EOF
#               #!/bin/bash
#               apt-get update
#               apt-get install -y apache2
#               sed -i -e 's/80/8080/' /etc/apache2/ports.conf
#               echo "Hello World" > /var/www/html/index.html
#               systemctl restart apache2
#               EOF
}

resource "aws_security_group" "web-sg" {
  name = "${random_pet.sg.id}-sg"
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // connectivity to ubuntu mirrors is required to run `apt-get update` and `apt-get install apache2`
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "web-address" {
  value = "${aws_instance.web.public_ip}:8443/nifi"
}
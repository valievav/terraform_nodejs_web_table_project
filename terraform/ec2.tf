/*
1. create EC2
2. create security group
  - 22 (to connect to ec2 via ssh)
  - 443 (for https access)
  - 3000 (for nodejs app) // ip:3000
 */

# define default vpc (instead of hardcoding the vpc id)
data "aws_vpc" "default" {
  default = true
}

# ec2
resource "aws_instance" "tf_ec2" {
  ami           = "ami-0a94c8e4ca2674d5a"  # ubuntu image
  instance_type = "t2.micro"
  associate_public_ip_address = true  # give public IP address
  key_name      = "terraform_ec2"  # created manually and saved to .ssh/terraform_ec2.pem
  vpc_security_group_ids = [aws_security_group.tf_ec2_sg.id]

  tags = {
    Name = "ec2_nodejs_server"
  }
}

# ec2 security group
resource "aws_security_group" "tf_ec2_sg" {
  name        = "ec2_nodejs_sg"
  description = "Allow SSH and HTTP access"
  vpc_id      = data.aws_vpc.default.id  # use data instead of hardcoding the vpc id

  # inbound rules
  ingress {
    description = "TLS"  # for https
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # allow all IPs
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # allow all IPs
  }

  ingress {
    description = "TCP"  # for general app access
    from_port = 3000
    to_port   = 3000
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # allow all IPs
  }

  # outbound rules
  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"  # all protocols
    cidr_blocks = ["0.0.0.0/0"]  # allow all IPs
  }
}

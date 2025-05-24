/*
1. create EC2
2. create security group
  - 22 (to connect to ec2 via ssh)
  - 443 (for https access)
  - 3000 (for nodejs app) // ip:3000
 */

# ec2
resource "aws_instance" "tf_ec2" {
  ami           = "ami-0a94c8e4ca2674d5a"  # ubuntu image
  instance_type = "t2.micro"
  associate_public_ip_address = true  # give public IP address
  key_name      = "terraform_ec2"  # created manually and saved to .ssh/terraform_ec2.pem
  vpc_security_group_ids = [aws_security_group.tf_ec2_sg.id]
  depends_on = [aws_s3_object.tf_s3_object]  # make sure s3 bucket created first, and ec2 after that

  # setup commands to run on instance creation
  user_data                   = <<-EOF
                                  #!/bin/bash

                                  # Git clone
                                  git clone https://github.com/verma-kunal/nodejs-mysql.git /home/ubuntu/nodejs-mysql
                                  cd /home/ubuntu/nodejs-mysql

                                  # install nodejs
                                  sudo apt update -y
                                  sudo apt install -y nodejs npm

                                  # edit env vars
                                  echo "DB_HOST=${local.rds_endpoint}" | sudo tee .env
                                  echo "DB_USER=${aws_db_instance.tf_rds.username}" | sudo tee -a .env
                                  sudo echo "DB_PASS=${aws_db_instance.tf_rds.password}" | sudo tee -a .env
                                  echo "DB_NAME=${aws_db_instance.tf_rds.db_name}" | sudo tee -a .env
                                  echo "TABLE_NAME=users" | sudo tee -a .env
                                  echo "PORT=3000" | sudo tee -a .env

                                  # start server
                                  npm install
                                  EOF

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

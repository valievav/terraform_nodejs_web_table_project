/*
1. rds resource
2. rds security group
   - 3306 port (via security group)
   - cidr_block => local_ip
 */

# db instance
resource "aws_db_instance" "tf_rds" {
  allocated_storage = 10
  identifier = "nodejs-mysql-instance"  # instance name
  db_name = "nodejs_mysql_db"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  username = "admin"
  password = "admin123"
  parameter_group_name = "default.mysql8.0"  # use default params for db config
  skip_final_snapshot = true
  publicly_accessible = true  # to ssh into db
  vpc_security_group_ids = [aws_security_group.tf_rds_sg.id]
}

# security group for db to allow certain type of access
resource "aws_security_group" "tf_rds_sg" {
  vpc_id      = data.aws_vpc.default.id
  name        = "allow_mysql"
  description = "Allow MySQL access"

  # inbound rule to connect to MySQL
  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["176.122.119.20/32"]  # to be accessible to local IP
    security_groups = [aws_security_group.tf_ec2_sg.id]  # to be accessible to ec2
  }

  # outbound rule to allow all traffic
  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"  # all protocols
    cidr_blocks = ["0.0.0.0/0"]  # allow all IPs
  }
}

locals {
  rds_endpoint = element(split(":", aws_db_instance.tf_rds.endpoint), 0)  # endpoint w/o port, 3306 is default anyways
}

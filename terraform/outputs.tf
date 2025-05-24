################## params

output "ec2_public_ip" {
  value = aws_instance.tf_ec2.public_ip
  description = "EC2 instance public IP"
}

output "rds_endpoint" {
  value = local.rds_endpoint
  description = "RDS endpoint without port"
}

output "db_name" {
  value = aws_db_instance.tf_rds.db_name
  description = "DB name"
}

output "user_name" {
  value = aws_db_instance.tf_rds.username
  description = "User name"
}

################## connection strings

output "ssh_connect_ec2_public_ip" {
  value = "ssh -i ~/.ssh/terraform_ec2.pem ubuntu@${aws_instance.tf_ec2.public_ip}"
  description = "SSH command for EC2 instance"
}

output "connect_rds_endpoint" {
  value = "mysql -h ${local.rds_endpoint} -u ${aws_db_instance.tf_rds.username} -p"
  description = "Connection command for RDS endpoint"
}

output "ec2_public_ip_ssh_command" {
  value = "ssh -i ~/.ssh/terraform_ec2.pem ubuntu@${aws_instance.tf_ec2.public_ip}"
  description = "SSH command for EC2 instance"
}

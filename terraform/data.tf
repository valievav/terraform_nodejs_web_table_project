# define default vpc to use for ec2 and rds
data "aws_vpc" "default" {
  default = true
}
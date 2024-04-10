data "aws_ami" "ami" {
  #own by me
  owners      = ["self"]
  most_recent = true
  filter {
    name   = "tag:AmiType"
    values = ["dev-mongodb7"]
  }
}

data "aws_route53_zone" "private_zone" {
  name         = var.common_private_zone
  private_zone = true
}
# vpc
data "aws_vpc" "vpc" {
  id = var.vpc_id
}
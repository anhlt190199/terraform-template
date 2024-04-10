data "aws_route53_zone" "commons" {
  name         = "${var.common_private_zone}."
  private_zone = true
}

# get vpc cidr block
data "aws_vpc" "vpc" {
  id = var.vpc_id
}

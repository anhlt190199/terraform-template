data "aws_ami" "ami" {
  #own by me
  owners      = ["self"]
  most_recent = true
  filter {
    name   = "tag:AmiType"
    values = ["vpn"]
  }
}

data "aws_route53_zone" "commons" {
  name         = "${var.common_domain_name}."
  private_zone = false
}
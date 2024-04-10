data  "aws_subnet" "vpc_private_subnet" {
  for_each = { for k,v in module.vpc.private_subnets: k => v }
  id = each.value
}

output "vpc_private_subnet_avail_ip_count_0" {
  value = {
    range = data.aws_subnet.vpc_private_subnet[0].cidr_block,
    availability_ip_count = data.aws_subnet.vpc_private_subnet[0].available_ip_address_count
  }
}

output "vpc_private_subnet_avail_ip_count_1" {
  value = {
    range = data.aws_subnet.vpc_private_subnet[1].cidr_block,
    availability_ip_count = data.aws_subnet.vpc_private_subnet[1].available_ip_address_count
  }
}

output "vpc_private_subnet_avail_ip_count_2" {
  value = {
    range = data.aws_subnet.vpc_private_subnet[2].cidr_block,
    availability_ip_count = data.aws_subnet.vpc_private_subnet[2].available_ip_address_count
  }
}
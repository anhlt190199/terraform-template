# output aws_security_group.SG_vpn
output "security_group_id" {
  value = aws_security_group.sg_dev_mongodb7.id
}
# output aws_security_group.SG_vpn
output "security_group_id" {
  value = aws_security_group.SG_vpn.id
}

output "vpn_public_ip" {
  value = aws_eip.vpn.public_ip
}
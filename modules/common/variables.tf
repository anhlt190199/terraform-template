#--- user mapping
variable "common_name_prefix" {
  type        = string
  description = "Name prefix (apply prefix name role config)"
}
#variable "common_aws_caller_identity" {
#  type        = string
#  description = "ID Account AWS"
#}
##--- vpc
#variable "vpc_id" {
#  type        = string
#  description = "The VPC ID"
#}
#variable "vpc_private_subnets" {
#  description = "List Private Subnet"
#  type        = list(string)
#}
##vpn_security_group_id
#variable "vpn_security_group_id" {
#  type        = string
#  description = "The ID of the security group to assign to the network interface"
#}
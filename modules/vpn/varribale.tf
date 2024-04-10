# common ---------------
variable "common_domain_name" {
  type        = string
  description = "Primary domain (selected from hosted zone)."
}

# vpc_id
variable "vpc_id" {
  type = string
}
variable "subnet_id" {
  type = string
}


variable "instance_type" {
  type = string
}
#variable "public_key" {
#    default = "vpn.pub"
#}
# variable "vpc_security" {
#     type = list

# }

#eks_config_cluster_name
variable "eks_config_cluster_name" {
  type = string
}

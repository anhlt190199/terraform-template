# common ---------------
variable "common_private_zone" {
  type        = string
  description = "Private zone name"
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

#ebs
variable "dev_database_availability_zone" {
  type = string
}

variable "dev_database_volume_type" {
  type = string
}

variable "dev_database_volume_iops" {
  type = number
}

variable "dev_database_volume_size" {
  type = number
}
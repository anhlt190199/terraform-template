variable "common_environment" {
  type        = string
  description = "EKS cluster environment."
}

#---- vpc variable
variable "eks_config_cluster_name" {
  type        = string
  description = "EKS cluster name."
}
variable "vpc_main_network_block" {
  type        = string
  description = "Base CIDR block to be used in our VPC."
}

variable "vpc_subnet_prefix_extension" {
  type        = number
  description = "CIDR block bits extension to calculate CIDR blocks of each subnetwork."
}
variable "vpc_zone_offset" {
  type        = number
  description = "CIDR block bits extension offset to calculate Public subnets, avoiding collisions with Private subnets."
}

# create_private_zone
variable "create_private_zone" {
  type        = bool
  description = "Create a private zone for the VPC."
  default     = true
}

# common_private_zone
variable "common_private_zone" {
  type        = string
  description = "Private zone name."
}
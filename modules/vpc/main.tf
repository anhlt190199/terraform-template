module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.19.0"
  name    = "${var.eks_config_cluster_name}-vpc"
  cidr    = var.vpc_main_network_block
  azs     = data.aws_availability_zones.available_azs.names

  # private_subnets = [
  #   # with a length depending on how many Zones are available
  #   for zone_id in data.aws_availability_zones.available_azs.zone_ids :
  # cidrsubnet(var.vpc_main_network_block, var.vpc_subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) - 1)]

  # add more private subnet
   private_subnets = concat([
    for zone_id in data.aws_availability_zones.available_azs.zone_ids :
    cidrsubnet(var.vpc_main_network_block, var.vpc_subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) - 1)],
    ["172.60.20.0/22"], ["172.60.24.0/22"], ["172.60.28.0/22"], ["172.60.32.0/22"] )
  public_subnets = [
    # with a length depending on how many Zones are available
    # there is a zone Offset variable, to make sure no collisions are present with private subnet blocks
    for zone_id in data.aws_availability_zones.available_azs.zone_ids :
    cidrsubnet(var.vpc_main_network_block, var.vpc_subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + var.vpc_zone_offset - 1)
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true
  reuse_nat_ips          = true
  external_nat_ip_ids    = data.aws_eips.nat_gw_elastic_ip.allocation_ids


  # add VPC/Subnet tags required by EKS
  tags = {
    "kubernetes.io/cluster/${var.eks_config_cluster_name}" = "shared"
    "kubernetes.io/cluster-name"                           = var.eks_config_cluster_name
    "kubernetes.io/environment"                            = var.common_environment
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_config_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                               = "1"
    tier                                                   = "public"

    # custom tag
    "kubernetes.io/cluster-name" = var.eks_config_cluster_name
    "kubernetes.io/environment"  = var.common_environment
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_config_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                      = "1"
    tier                                                   = "private"

    # custom tag
    "kubernetes.io/cluster-name" = var.eks_config_cluster_name
    "kubernetes.io/environment"  = var.common_environment
    "karpenter.sh/discovery" = var.eks_config_cluster_name
  }
}

#route 53 private zone
resource "aws_route53_zone" "private_zone" {
  count = var.create_private_zone ? 1 : 0
  name  = var.common_private_zone
  vpc {
    vpc_id = module.vpc.vpc_id
  }
  comment       = "Private zone for ${var.common_private_zone}"
  force_destroy = true
}
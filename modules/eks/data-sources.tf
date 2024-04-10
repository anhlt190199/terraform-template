data "aws_region" "current" {}
data "aws_availability_zones" "available_azs" {
  state = "available"
}

data "aws_eks_cluster" "cluster" {
  #  name = module.eks_cluster.cluster_id
  name = module.eks_cluster.cluster_name
  # depends_on = [module.eks_cluster.cluster_certificate_authority_data]
}

data "aws_eks_cluster_auth" "cluster" {
  #  name = module.eks_cluster.cluster_id
  name = module.eks_cluster.cluster_name
  # depends_on = [module.eks_cluster.cluster_certificate_authority_data]
}

data "aws_route53_zone" "commons" {
  #  name         = "${var.common_domain_name}."
  #  private_zone = false
  name         = "${var.common_private_zone}."
  private_zone = true
  depends_on   = [var.common_private_zone]
}

